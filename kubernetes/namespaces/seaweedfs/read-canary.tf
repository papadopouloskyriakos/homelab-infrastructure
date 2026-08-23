# =============================================================================
# SeaweedFS READ-path canary (IFRNLLEI01PRD-2605 phase 6)
#
# The 2026-07/08 corruption incidents and the 2026-08-23 restore-drill failure
# (ModSecurity truncating a 2GB barman base GET at exactly 512MiB, clean EOF)
# were all invisible to write-path monitoring: "a readability test is not a
# correctness test", and nothing at all read LARGE objects end-to-end.
#
# Every 6h this CronJob, using the scoped read-canary identity:
#   1. PUTs a 1MiB random object via the canary endpoint, GETs it back,
#      verifies SHA256, DELETEs it (small write/read roundtrip);
#   2. streams the 1GiB sentinel object (read-canary/sentinel-1g.bin, seeded
#      once per site) through the SAME endpoint its real consumers use and
#      verifies full length + SHA256 against read-canary/sentinel-1g.sha.
#      1GiB is deliberately past every truncation cut point seen (256/512MiB).
#
# canary_s3_endpoint is per-site: NL/GR test their PUBLIC ingress path (what
# barman/velero/uploads ride); notrf01 tests the cluster-local service (its
# only consumers — loki/thanos — are cluster-local; no-s3 has no DNS).
# Failure => Job fails => SeaweedFSReadCanary* rules in
# namespaces/monitoring/seaweedfs-write-path-alerts.tf.
# =============================================================================

resource "kubernetes_manifest" "read_canary_externalsecret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "seaweedfs-read-canary-s3"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "seaweedfs"
        "app.kubernetes.io/component"  = "read-canary"
        "app.kubernetes.io/managed-by" = "opentofu"
        "environment"                  = "production"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef  = { name = "openbao", kind = "ClusterSecretStore" }
      target          = { name = "seaweedfs-read-canary-s3", creationPolicy = "Owner", deletionPolicy = "Retain" }
      data = [
        { secretKey = "ACCESS_KEY_ID", remoteRef = { key = "REDACTED_e2d03eb1", property = "ACCESS_KEY_ID" } },
        { secretKey = "ACCESS_SECRET_KEY", remoteRef = { key = "REDACTED_e2d03eb1", property = "ACCESS_SECRET_KEY" } },
      ]
    }
  }
  depends_on = [REDACTED_46569c16.seaweedfs]
}

resource "REDACTED_a9df2e77_v1" "read_canary_script" {
  metadata {
    name      = "REDACTED_68ab59ec"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "seaweedfs"
      "app.kubernetes.io/component"  = "read-canary"
      "app.kubernetes.io/managed-by" = "opentofu"
      "environment"                  = "production"
    }
  }
  data = {
    "canary.py" = <<-PYEOF
      import hashlib, hmac, os, sys, datetime, urllib.request, urllib.parse, ssl, secrets, time

      AK, SK = os.environ["ACCESS_KEY_ID"], os.environ["ACCESS_SECRET_KEY"]
      ENDPOINT = os.environ["S3_ENDPOINT"].rstrip("/")
      REGION, SERVICE = "seaweedfs", "s3"
      u = urllib.parse.urlparse(ENDPOINT)
      HOST = u.netloc
      CTX = ssl._create_unverified_context() if u.scheme == "https" else None

      def sv4(method, path, body=b"", stream=False):
          t = datetime.datetime.now(datetime.UTC)
          amz, ds = t.strftime("%Y%m%dT%H%M%SZ"), t.strftime("%Y%m%d")
          ph = hashlib.sha256(body).hexdigest()
          ch = "host:%s\nREDACTED_3c0ef42e:%s\nx-amz-date:%s\n" % (HOST, ph, amz)
          sh = "host;REDACTED_3c0ef42e;x-amz-date"
          cr = "%s\n%s\n\n%s\n%s\n%s" % (method, path, ch, sh, ph)
          scope = "%s/%s/%s/aws4_request" % (ds, REGION, SERVICE)
          sts = "AWS4-HMAC-SHA256\n%s\n%s\n%s" % (amz, scope, hashlib.sha256(cr.encode()).hexdigest())
          k = hmac.new(("AWS4" + SK).encode(), ds.encode(), hashlib.sha256).digest()
          for x in (REGION, SERVICE, "aws4_request"):
              k = hmac.new(k, x.encode(), hashlib.sha256).digest()
          sig = hmac.new(k, sts.encode(), hashlib.sha256).hexdigest()
          r = urllib.request.Request(ENDPOINT + path, data=body if method == "PUT" else None, method=method)
          r.add_header("x-amz-date", amz)
          r.add_header("REDACTED_3c0ef42e", ph)
          r.add_header("Authorization",
                       "AWS4-HMAC-SHA256 Credential=%s/%s, SignedHeaders=%s, Signature=%s" % (AK, scope, sh, sig))
          resp = urllib.request.urlopen(r, timeout=600, context=CTX)
          if not stream:
              return resp.status, resp.read()
          h, n = hashlib.sha256(), 0
          while True:
              b = resp.read(1 << 22)
              if not b:
                  break
              h.update(b)
              n += len(b)
          return resp.status, (n, h.hexdigest())

      fail = 0

      # 1. small write/read/delete roundtrip
      blob = secrets.token_bytes(1 << 20)
      want = hashlib.sha256(blob).hexdigest()
      key = "/read-canary/roundtrip.bin"
      st, _ = sv4("PUT", key, blob)
      st2, got = sv4("GET", key)
      have = hashlib.sha256(got).hexdigest()
      sv4("DELETE", key)
      if st != 200 or st2 != 200 or have != want:
          print("ROUNDTRIP FAIL put=%s get=%s sha_ok=%s" % (st, st2, have == want))
          fail = 1
      else:
          print("roundtrip ok")

      # 2. 1GiB sentinel stream + verify
      try:
          _, sha_bytes = sv4("GET", "/read-canary/sentinel-1g.sha")
          want_sha = sha_bytes.decode().split()[0]
          t0 = time.time()
          st, (n, have_sha) = sv4("GET", "/read-canary/sentinel-1g.bin", stream=True)
          ok = st == 200 and n == 1073741824 and have_sha == want_sha
          print("sentinel %s: %d bytes in %.0fs sha_ok=%s" % ("ok" if ok else "FAIL", n, time.time() - t0, have_sha == want_sha))
          if not ok:
              fail = 1
      except Exception as e:
          print("sentinel FAIL: %s: %s" % (type(e).__name__, e))
          fail = 1

      sys.exit(fail)
    PYEOF
  }
}

resource "kubernetes_manifest" "read_canary_cronjob" {
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "seaweedfs-read-canary"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "seaweedfs"
        "app.kubernetes.io/component"  = "read-canary"
        "app.kubernetes.io/managed-by" = "opentofu"
        "environment"                  = "production"
      }
    }
    spec = {
      schedule                   = "23 */6 * * *"
      concurrencyPolicy          = "Forbid"
      successfulJobsHistoryLimit = 3
      failedJobsHistoryLimit     = 3
      jobTemplate = {
        spec = {
          backoffLimit          = 1
          activeDeadlineSeconds = 1200
          template = {
            metadata = {
              labels = { "app.kubernetes.io/name" = "seaweedfs-read-canary" }
            }
            spec = {
              restartPolicy = "Never"
              containers = [
                {
                  name    = "canary"
                  image   = "python:3.12-alpine"
                  command = ["python3", "/canary/canary.py"]
                  env = [
                    { name = "S3_ENDPOINT", value = var.canary_s3_endpoint },
                    { name = "ACCESS_KEY_ID", valueFrom = { REDACTED_5dfff400 = { name = "seaweedfs-read-canary-s3", key = "ACCESS_KEY_ID" } } },
                    { name = "ACCESS_SECRET_KEY", valueFrom = { REDACTED_5dfff400 = { name = "seaweedfs-read-canary-s3", key = "ACCESS_SECRET_KEY" } } },
                  ]
                  resources = {
                    requests = { cpu = "50m", memory = "64Mi" }
                    limits   = { memory = "256Mi" }
                  }
                  volumeMounts = [{ name = "script", mountPath = "/canary" }]
                }
              ]
              volumes = [
                { name = "script", configMap = { name = "REDACTED_68ab59ec" } }
              ]
            }
          }
        }
      }
    }
  }
  depends_on = [REDACTED_a9df2e77_v1.read_canary_script, kubernetes_manifest.read_canary_externalsecret]
}
