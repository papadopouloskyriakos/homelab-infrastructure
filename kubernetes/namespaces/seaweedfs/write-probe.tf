# =============================================================================
# SeaweedFS per-VOLUME-SERVER write probe (IFRNLLEI01PRD-2850, 2026-09-23)
#
# On 2026-09-22 04:16Z seaweedfs-volume-0's data filesystem went ext4
# `emergency_ro` (both volume servers had been OOM-killed an hour earlier). The
# mount still says `rw` and node_filesystem_readonly stays 0 in that state, so
# nothing named the fault. Every consequence DID alert: write assigns failing,
# the other server pinned at the free-space floor by half-written replicas,
# dead reclaimers, halted compactor, failing read canary. Seven tier-1 alerts,
# 61 phone pushes in 43 hours, and the cause was found by hand two days later.
#
# This probe asks the master for a write slot PINNED to each data node
# (/dir/assign?dataNode=...), uploads 4 KiB straight to that volume server and
# deletes it again. A server whose filesystem refuses writes answers HTTP 500
# ("read-only file system"). An assign REFUSAL (no writable volume on that node:
# low-space protection or the slot ceiling) is NOT a filesystem verdict and is
# reported without failing the Job: REDACTED_cc66fa91 owns that.
#
# Failure => Job fails => REDACTED_47595c82 (tier 1) in
# namespaces/monitoring/seaweedfs-write-path-alerts.tf, which inhibits the
# symptom alerts (Alertmanager inhibit_rules in namespaces/monitoring/main.tf).
# Cost: one tiny `write-probe` volume (replication 000) per data node.
# =============================================================================

resource "REDACTED_a9df2e77_v1" "write_probe_script" {
  metadata {
    name      = "REDACTED_7c48543b"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "seaweedfs"
      "app.kubernetes.io/component"  = "write-probe"
      "app.kubernetes.io/managed-by" = "opentofu"
      "environment"                  = "production"
    }
  }
  data = {
    "probe.py" = <<-PYEOF
      import json, os, secrets, sys, urllib.error, urllib.parse, urllib.request, uuid

      MASTER = os.environ.get("MASTER_URL", "http://seaweedfs-master:9333").rstrip("/")
      COLLECTION = os.environ.get("PROBE_COLLECTION", "write-probe")

      def http(url, method="GET", data=None, headers=None, timeout=30):
          req = urllib.request.Request(url, data=data, method=method, headers=headers or {})
          try:
              with urllib.request.urlopen(req, timeout=timeout) as resp:
                  return resp.status, resp.read()
          except urllib.error.HTTPError as e:
              return e.code, e.read()
          except Exception as e:  # connection refused, timeout, DNS
              return 0, ("%s: %s" % (type(e).__name__, e)).encode()

      st, body = http(MASTER + "/dir/status")
      if st != 200:
          print("MASTER FAIL: /dir/status http %s %s" % (st, body[:200].decode(errors="replace")))
          sys.exit(2)
      topo = json.loads(body)["Topology"]
      nodes = sorted(dn["Url"] for dc in topo.get("DataCenters", [])
                     for rack in dc.get("Racks", []) for dn in rack.get("DataNodes", []))
      if not nodes:
          print("MASTER FAIL: topology lists no data nodes")
          sys.exit(2)

      bad = 0
      for node in nodes:
          q = urllib.parse.urlencode({"collection": COLLECTION, "replication": "000",
                                      "dataNode": node, "writableVolumeCount": "1"})
          st, body = http("%s/dir/assign?%s" % (MASTER, q))
          try:
              a = json.loads(body)
          except Exception:
              a = {"error": body[:200].decode(errors="replace")}
          if st != 200 or "fid" not in a:
              print("%s: assign refused (%s): no filesystem verdict - low space or slot ceiling, see REDACTED_cc66fa91"
                    % (node, a.get("error", "http %s" % st)))
              continue
          if a.get("url") != node:
              print("%s: assign landed on %s, pin not honoured: no verdict" % (node, a.get("url")))
              continue
          fid = a["fid"]
          payload = secrets.token_bytes(4096)
          boundary = uuid.uuid4().hex
          mp = (("--%s\r\nContent-Disposition: form-data; name=\"file\"; filename=\"probe.bin\"\r\n"
                 "Content-Type: application/octet-stream\r\n\r\n") % boundary).encode() \
               + payload + ("\r\n--%s--\r\n" % boundary).encode()
          st, body = http("http://%s/%s" % (node, fid), "POST", mp,
                          {"Content-Type": "multipart/form-data; boundary=%s" % boundary})
          text = body.decode(errors="replace")[:300]
          if st in (200, 201):
              http("http://%s/%s" % (node, fid), "DELETE")
              print("%s: write ok (%d B, fid %s)" % (node, len(payload), fid))
          else:
              bad += 1
              print("%s: WRITE FAIL http %s: %s" % (node, st, text))

      sys.exit(1 if bad else 0)
    PYEOF
  }
}

resource "kubernetes_manifest" "write_probe_cronjob" {
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "seaweedfs-write-probe"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "seaweedfs"
        "app.kubernetes.io/component"  = "write-probe"
        "app.kubernetes.io/managed-by" = "opentofu"
        "environment"                  = "production"
      }
    }
    spec = {
      schedule                   = "*/10 * * * *"
      concurrencyPolicy          = "Forbid"
      startingDeadlineSeconds    = 300
      successfulJobsHistoryLimit = 1
      failedJobsHistoryLimit     = 3
      jobTemplate = {
        spec = {
          # Short TTL: 144 Jobs/day otherwise pile up in kube-state-metrics. The
          # alert window (30 min) is well inside it.
          ttlSecondsAfterFinished = 3600
          backoffLimit            = 0
          activeDeadlineSeconds   = 300
          template = {
            metadata = {
              labels = { "app.kubernetes.io/name" = "seaweedfs-write-probe" }
            }
            spec = {
              restartPolicy = "Never"
              containers = [
                {
                  name    = "probe"
                  image   = "python:3.12-alpine"
                  command = ["python3", "/probe/probe.py"]
                  env = [
                    { name = "MASTER_URL", value = "http://seaweedfs-master:9333" },
                    { name = "PROBE_COLLECTION", value = "write-probe" },
                  ]
                  resources = {
                    requests = { cpu = "20m", memory = "32Mi" }
                    limits   = { memory = "128Mi" }
                  }
                  volumeMounts = [{ name = "script", mountPath = "/probe" }]
                }
              ]
              volumes = [
                { name = "script", configMap = { name = "REDACTED_7c48543b" } }
              ]
            }
          }
        }
      }
    }
  }
  depends_on = [REDACTED_a9df2e77_v1.write_probe_script]
}
