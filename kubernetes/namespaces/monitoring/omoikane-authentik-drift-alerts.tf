# =============================================================================
# omoikane authentik derived-image drift alerts — OMOIKANE-1594 / ADR-0017.
#
# Production does NOT run upstream authentik. It runs a DERIVED image,
# `omoikane-authentik:<tag>-omk`, built from the daemon repo's
# auth/Dockerfile.pyjwt, which forces PyJWT >= 2.13.0 to close CVE-2026-48526
# (REDACTED_6fa691d2 bypass via a forged JWT — in an identity provider that is
# full account takeover, reachable unauthenticated).
#
# Why a derived image instead of upgrading: authentik 2026.5.x migrations
# create a plain index on a JSONB column and YugabyteDB refuses it
# ("INDEX on column of type 'JSONB' not yet supported"). Attempted on
# production 2026-08-02 — gunicorn crash-looped and auth 503'd for ~4 min
# before rollback. Verified against the NEWEST YB (2026.1.0.1) too: same
# error, so upgrading YB does not unblock it. There is no intermediate
# authentik either (release line goes 2026.2.6 -> 2026.5.0).
#
# THE FAILURE MODE THESE RULES EXIST FOR: upstream ships an authentik security
# release, nobody rebuilds the derived image, and the estate quietly runs old
# authentik forever. Nothing about that looks broken — containers healthy, auth
# serving, dashboards green. It rots SILENTLY. That is why it needs a rule and
# not a note in a runbook.
#
# Feed: `omoikane-authentik-image-drift.sh`, a node_exporter textfile collector
# installed on notrf01dmz01/02 by the daemon repo
# (monitoring/host-metrics/, weekly systemd timer). It emits:
#   omoikane_authentik_release_behind{pinned}  upstream releases newer than ours
#                                              (-1 = THE CHECK ITSELF FAILED)
#   omoikane_authentik_pyjwt_ok{version}       1 = RUNNING container >= 2.13
#   omoikane_authentik_drift_check_ts          unix ts of last SUCCESSFUL check
#
# SELECTOR NOTE — the estate-wide trap: notrf01dmz01-04 are scraped under
# Prometheus job "omoikane-node", NOT "node-exporter-edge". A rule written
# against the wrong job matches nothing and is an ABSENT rule, not a quiet one
# (the OMOIKANE-1493 lesson). These metrics were confirmed present before this
# file was written:
#   curl -s 'http://nl-prometheus.example.net/api/v1/query?query=omoikane_authentik_release_behind'
#   -> notrf01dmz01 job=omoikane-node = 6 ; notrf01dmz02 job=omoikane-node = 6
#
# `-1` and `0` are deliberately different values in the feed: "check failed" and
# "no drift" must never be the same number. The first version of the collector
# reported 0-behind while sitting SIX releases behind, because authentik tags
# are `version/2026.5.6` and the parser expected a bare version. Hence the
# explicit == -1 rule below rather than folding it into a > 0 threshold.
# =============================================================================

resource "kubernetes_manifest" "omoikane_authentik_drift_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "omoikane-authentik-drift-alert-rules"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "prometheus"                = "monitoring"
        "role"                      = "alert-rules"
        "release"                   = "monitoring"
      }
    }
    spec = {
      groups = [
        {
          name     = "omoikane-authentik-drift"
          interval = "5m"
          rules = [
            {
              # THE ONE THAT MATTERS MOST. The running container's PyJWT is
              # below the CVE-2026-48526 fix, which means the forged-JWT
              # REDACTED_6fa691d2 bypass is OPEN on the estate's front door.
              # Reads the RUNNING container, not the image and not the
              # Dockerfile — an image built correctly but never deployed, or a
              # container recreated from a stale local image, both land here.
              alert = "OmoikaneAuthentikPyJWTUnpatched"
              expr  = "omoikane_authentik_pyjwt_ok == 0"
              for   = "15m"
              labels = {
                severity = "critical"
                category = "omoikane-security"
              }
              annotations = {
                summary     = "authentik on {{ $labels.instance }} is running UNPATCHED PyJWT ({{ $labels.version }}) — auth bypass OPEN"
                description = "The RUNNING authentik container on {{ $labels.instance }} has PyJWT {{ $labels.version }}, below 2.13.0, so CVE-2026-48526 (REDACTED_6fa691d2 bypass via forged JWT) is exploitable against auth.omoikane.coach. This is the single worst exposure in the estate: authentik is the front door to every authenticated surface. Almost certainly a container recreated from the upstream image instead of omoikane-authentik:<tag>-omk. FIX: cd /srv/omoikane-daemon/auth && docker build -f Dockerfile.pyjwt -t omoikane-authentik:$${AUTHENTIK_TAG}-omk . && docker compose up -d --force-recreate server worker, then verify with docker exec omoikane-auth-server python -c 'import jwt; print(jwt.__version__)'. See ADR-0017."
              }
            },
            {
              # Upstream has shipped release(s) newer than our pin. Not urgent
              # by itself — we are pinned deliberately — but each new release
              # may carry a security fix that our derived image does not have,
              # and the derived image only gets rebuilt if a human is told to.
              # 8h before firing: releases land in bursts and this is a
              # "someone should look this week" signal, not a pager.
              alert = "OmoikaneAuthentikReleaseBehind"
              expr  = "omoikane_authentik_release_behind > 0"
              for   = "8h"
              labels = {
                severity = "warning"
                category = "omoikane-security"
              }
              annotations = {
                summary     = "authentik is {{ $value }} release(s) behind upstream on {{ $labels.instance }} (pinned {{ $labels.pinned }})"
                description = "Upstream has {{ $value }} release(s) newer than our pinned {{ $labels.pinned }}. We are pinned DELIBERATELY — authentik 2026.5.x cannot run on YugabyteDB (ADR-0017) — so this is NOT a request to upgrade. It is a request to CHECK whether any of those releases carries a security fix that must be back-ported into auth/Dockerfile.pyjwt, the same way PyJWT was. Review https://github.com/goauthentik/authentik/releases and rebuild the derived image if needed."
              }
            },
            {
              # Dead-man for the collector itself. A check that stops running
              # leaves its last good value in place and reads as healthy
              # forever — the OMOIKANE-1516 lesson (a monitoring job that fails
              # silently is worse than no monitoring job). The collector runs
              # weekly, so 10 days is ~1.4 missed runs: long enough to absorb
              # the timer's 2h randomised delay and a reboot, short enough to
              # notice before a second cycle is lost.
              alert = "OmoikaneAuthentikDriftCheckStale"
              expr  = "time() - omoikane_authentik_drift_check_ts > 864000"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "omoikane-security"
              }
              annotations = {
                summary     = "authentik drift check has not succeeded in 10+ days on {{ $labels.instance }}"
                description = "omoikane_authentik_drift_check_ts on {{ $labels.instance }} is >10 days old, so the weekly derived-image drift check is dark and the two rules above are running on stale data that still reads as healthy. Check: systemctl status omoikane-authentik-drift.timer / journalctl -u omoikane-authentik-drift.service on the host. NOTE the timestamp is stamped ONLY on a successful upstream query, so an unreachable GitHub also surfaces here rather than being mistaken for no-drift."
              }
            },
            {
              # The collector ran but could not determine the answer (-1).
              # Distinct from "0 behind" ON PURPOSE: conflating them is exactly
              # how a broken check certifies a healthy system.
              alert = "OmoikaneAuthentikDriftCheckFailing"
              expr  = "omoikane_authentik_release_behind == -1"
              for   = "1h"
              labels = {
                severity = "warning"
                category = "omoikane-security"
              }
              annotations = {
                summary     = "authentik drift check cannot read upstream releases on {{ $labels.instance }}"
                description = "The collector on {{ $labels.instance }} reported -1: it could not reach the GitHub releases API, or the release tag format changed and nothing parsed. The latter already happened once — authentik tags are `version/2026.5.6`, and a parser expecting a bare version silently reported '0 behind' while six releases behind, which is why -1 exists as a distinct value. Verify by hand: curl -s 'https://api.github.com/repos/goauthentik/authentik/releases?per_page=5' | grep tag_name, then fix the parser in the daemon repo at monitoring/host-metrics/omoikane-authentik-drift.sh."
              }
            },
          ]
        },
      ]
    }
  }
}
