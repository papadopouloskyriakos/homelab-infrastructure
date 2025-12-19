# ========================================================================
# Tetragon Grafana Dashboard
# ========================================================================
# Deploys a Grafana dashboard for Tetragon security observability
# Includes panels for:
# - Process execution events
# - Sensitive file access
# - kubectl exec audit
# - Tetragon agent health metrics
# ========================================================================

resource "REDACTED_9343442e" "tetragon_grafana_dashboard" {
  count = var.enable_grafana_dashboard ? 1 : 0

  metadata {
    name      = "tetragon-security-dashboard"
    namespace = var.REDACTED_060311fa
    labels = {
      "app.kubernetes.io/name"       = "tetragon-dashboard"
      "app.kubernetes.io/component"  = "grafana"
      "app.kubernetes.io/managed-by" = "opentofu"
      # Label for Grafana sidecar to auto-import
      (var.grafana_sidecar_label) = "1"
    }
  }

  data = {
    "tetragon-security.json" = jsonencode({
      annotations = {
        list = [
          {
            builtIn    = 1
            datasource = { type = "grafana", uid = "-- Grafana --" }
            enable     = true
            hide       = true
            iconColor  = "rgba(0, 211, 255, 1)"
            name       = "Annotations & Alerts"
            type       = "dashboard"
          }
        ]
      }
      editable             = true
      fiscalYearStartMonth = 0
      graphTooltip         = 0
      id                   = null
      links                = []
      liveNow              = false
      panels = [
        # ================================================================
        # Row: Overview Stats
        # ================================================================
        {
          collapsed = false
          gridPos   = { h = 1, w = 24, x = 0, y = 0 }
          id        = 100
          panels    = []
          title     = "Overview"
          type      = "row"
        },
        # Stat: Total Events (Last Hour)
        {
          datasource = { type = "loki", uid = "$datasource_loki" }
          fieldConfig = {
            defaults = {
              color    = { mode = "thresholds" }
              mappings = []
              thresholds = {
                mode = "absolute"
                steps = [
                  { color = "green", value = null },
                  { color = "yellow", value = 1000 },
                  { color = "red", value = 10000 }
                ]
              }
              unit = "short"
            }
            overrides = []
          }
          gridPos = { h = 4, w = 4, x = 0, y = 1 }
          id      = 1
          options = {
            colorMode   = "value"
            graphMode   = "area"
            justifyMode = "auto"
            orientation = "auto"
            reduceOptions = {
              calcs  = ["count"]
              fields = ""
              values = false
            }
            textMode = "auto"
          }
          targets = [
            {
              datasource = { type = "loki", uid = "$datasource_loki" }
              expr       = "{job=\"tetragon\"} |= ``"
              refId      = "A"
            }
          ]
          title = "Total Events (1h)"
          type  = "stat"
        },
        # Stat: Process Exec Events
        {
          datasource = { type = "loki", uid = "$datasource_loki" }
          fieldConfig = {
            defaults = {
              color    = { mode = "thresholds" }
              mappings = []
              thresholds = {
                mode = "absolute"
                steps = [
                  { color = "blue", value = null }
                ]
              }
              unit = "short"
            }
            overrides = []
          }
          gridPos = { h = 4, w = 4, x = 4, y = 1 }
          id      = 2
          options = {
            colorMode   = "value"
            graphMode   = "area"
            justifyMode = "auto"
            orientation = "auto"
            reduceOptions = {
              calcs  = ["count"]
              fields = ""
              values = false
            }
            textMode = "auto"
          }
          targets = [
            {
              datasource = { type = "loki", uid = "$datasource_loki" }
              expr       = "{job=\"tetragon\"} |= `process_exec`"
              refId      = "A"
            }
          ]
          title = "Process Exec Events"
          type  = "stat"
        },
        # Stat: File Access Events
        {
          datasource = { type = "loki", uid = "$datasource_loki" }
          fieldConfig = {
            defaults = {
              color    = { mode = "thresholds" }
              mappings = []
              thresholds = {
                mode = "absolute"
                steps = [
                  { color = "orange", value = null }
                ]
              }
              unit = "short"
            }
            overrides = []
          }
          gridPos = { h = 4, w = 4, x = 8, y = 1 }
          id      = 3
          options = {
            colorMode   = "value"
            graphMode   = "area"
            justifyMode = "auto"
            orientation = "auto"
            reduceOptions = {
              calcs  = ["count"]
              fields = ""
              values = false
            }
            textMode = "auto"
          }
          targets = [
            {
              datasource = { type = "loki", uid = "$datasource_loki" }
              expr       = "{job=\"tetragon\"} |= `process_kprobe`"
              refId      = "A"
            }
          ]
          title = "Kprobe Events"
          type  = "stat"
        },
        # Stat: Tetragon Pods Running
        {
          datasource = { type = "prometheus", uid = "$datasource" }
          fieldConfig = {
            defaults = {
              color    = { mode = "thresholds" }
              mappings = []
              thresholds = {
                mode = "absolute"
                steps = [
                  { color = "red", value = null },
                  { color = "green", value = 1 }
                ]
              }
              unit = "short"
            }
            overrides = []
          }
          gridPos = { h = 4, w = 4, x = 12, y = 1 }
          id      = 4
          options = {
            colorMode   = "value"
            graphMode   = "none"
            justifyMode = "auto"
            orientation = "auto"
            reduceOptions = {
              calcs  = ["lastNotNull"]
              fields = ""
              values = false
            }
            textMode = "auto"
          }
          targets = [
            {
              datasource = { type = "prometheus", uid = "$datasource" }
              expr       = "count(up{job=\"tetragon\"})"
              refId      = "A"
            }
          ]
          title = "Tetragon Agents"
          type  = "stat"
        },
        # Gauge: Events per Second
        {
          datasource = { type = "prometheus", uid = "$datasource" }
          fieldConfig = {
            defaults = {
              color    = { mode = "thresholds" }
              mappings = []
              max      = 100
              min      = 0
              thresholds = {
                mode = "absolute"
                steps = [
                  { color = "green", value = null },
                  { color = "yellow", value = 50 },
                  { color = "red", value = 80 }
                ]
              }
              unit = "ops"
            }
            overrides = []
          }
          gridPos = { h = 4, w = 4, x = 16, y = 1 }
          id      = 5
          options = {
            orientation = "auto"
            reduceOptions = {
              calcs  = ["lastNotNull"]
              fields = ""
              values = false
            }
            showThresholdLabels  = false
            showThresholdMarkers = true
          }
          targets = [
            {
              datasource = { type = "prometheus", uid = "$datasource" }
              expr       = "sum(rate(tetragon_events_total[5m]))"
              refId      = "A"
            }
          ]
          title = "Events/sec"
          type  = "gauge"
        },
        # ================================================================
        # Row: Event Timeline
        # ================================================================
        {
          collapsed = false
          gridPos   = { h = 1, w = 24, x = 0, y = 5 }
          id        = 101
          panels    = []
          title     = "Event Timeline"
          type      = "row"
        },
        # Graph: Events Over Time
        {
          datasource = { type = "loki", uid = "$datasource_loki" }
          fieldConfig = {
            defaults = {
              color = { mode = "palette-classic" }
              custom = {
                axisCenteredZero = false
                axisColorMode    = "text"
                axisLabel        = ""
                axisPlacement    = "auto"
                barAlignment     = 0
                drawStyle        = "bars"
                fillOpacity      = 50
                gradientMode     = "none"
                hideFrom = {
                  legend  = false
                  tooltip = false
                  viz     = false
                }
                lineInterpolation = "linear"
                lineWidth         = 1
                pointSize         = 5
                scaleDistribution = { type = "linear" }
                showPoints        = "auto"
                spanNulls         = false
                stacking          = { group = "A", mode = "none" }
                thresholdsStyle   = { mode = "off" }
              }
              mappings = []
              thresholds = {
                mode  = "absolute"
                steps = [{ color = "green", value = null }]
              }
              unit = "short"
            }
            overrides = []
          }
          gridPos = { h = 8, w = 24, x = 0, y = 6 }
          id      = 6
          options = {
            legend = {
              calcs       = []
              displayMode = "list"
              placement   = "bottom"
              showLegend  = true
            }
            tooltip = { mode = "single", sort = "none" }
          }
          targets = [
            {
              datasource   = { type = "loki", uid = "$datasource_loki" }
              expr         = "sum by (event_type) (count_over_time({job=\"tetragon\"} | json | __error__=\"\" [$__interval]))"
              legendFormat = "{{event_type}}"
              refId        = "A"
            }
          ]
          title = "Events Over Time"
          type  = "timeseries"
        },
        # ================================================================
        # Row: Security Events Log
        # ================================================================
        {
          collapsed = false
          gridPos   = { h = 1, w = 24, x = 0, y = 14 }
          id        = 102
          panels    = []
          title     = "Security Events"
          type      = "row"
        },
        # Logs Panel: All Tetragon Events
        {
          datasource = { type = "loki", uid = "$datasource_loki" }
          gridPos    = { h = 12, w = 24, x = 0, y = 15 }
          id         = 7
          options = {
            dedupStrategy      = "none"
            enableLogDetails   = true
            prettifyLogMessage = true
            showCommonLabels   = false
            showLabels         = false
            showTime           = true
            sortOrder          = "Descending"
            wrapLogMessage     = false
          }
          targets = [
            {
              datasource = { type = "loki", uid = "$datasource_loki" }
              expr       = "{job=\"tetragon\"} | json | line_format \"{{.time}} [{{.process_exec.process.pod.namespace}}/{{.process_exec.process.pod.name}}] {{.process_exec.process.binary}} {{.process_exec.process.arguments}}\""
              refId      = "A"
            }
          ]
          title = "Tetragon Events Log"
          type  = "logs"
        },
        # ================================================================
        # Row: Agent Metrics
        # ================================================================
        {
          collapsed = true
          gridPos   = { h = 1, w = 24, x = 0, y = 27 }
          id        = 103
          panels = [
            # CPU Usage
            {
              datasource = { type = "prometheus", uid = "$datasource" }
              fieldConfig = {
                defaults = {
                  color = { mode = "palette-classic" }
                  custom = {
                    axisCenteredZero  = false
                    axisColorMode     = "text"
                    axisLabel         = ""
                    axisPlacement     = "auto"
                    barAlignment      = 0
                    drawStyle         = "line"
                    fillOpacity       = 10
                    gradientMode      = "none"
                    hideFrom          = { legend = false, tooltip = false, viz = false }
                    lineInterpolation = "linear"
                    lineWidth         = 1
                    pointSize         = 5
                    scaleDistribution = { type = "linear" }
                    showPoints        = "never"
                    spanNulls         = false
                    stacking          = { group = "A", mode = "none" }
                    thresholdsStyle   = { mode = "off" }
                  }
                  mappings = []
                  thresholds = {
                    mode  = "absolute"
                    steps = [{ color = "green", value = null }]
                  }
                  unit = "percentunit"
                }
                overrides = []
              }
              gridPos = { h = 8, w = 12, x = 0, y = 28 }
              id      = 8
              options = {
                legend  = { calcs = ["mean", "max"], displayMode = "table", placement = "bottom", showLegend = true }
                tooltip = { mode = "single", sort = "none" }
              }
              targets = [
                {
                  datasource   = { type = "prometheus", uid = "$datasource" }
                  expr         = "rate(process_cpu_seconds_total{job=\"tetragon\"}[5m])"
                  legendFormat = "{{pod}}"
                  refId        = "A"
                }
              ]
              title = "Tetragon CPU Usage"
              type  = "timeseries"
            },
            # Memory Usage
            {
              datasource = { type = "prometheus", uid = "$datasource" }
              fieldConfig = {
                defaults = {
                  color = { mode = "palette-classic" }
                  custom = {
                    axisCenteredZero  = false
                    axisColorMode     = "text"
                    axisLabel         = ""
                    axisPlacement     = "auto"
                    barAlignment      = 0
                    drawStyle         = "line"
                    fillOpacity       = 10
                    gradientMode      = "none"
                    hideFrom          = { legend = false, tooltip = false, viz = false }
                    lineInterpolation = "linear"
                    lineWidth         = 1
                    pointSize         = 5
                    scaleDistribution = { type = "linear" }
                    showPoints        = "never"
                    spanNulls         = false
                    stacking          = { group = "A", mode = "none" }
                    thresholdsStyle   = { mode = "off" }
                  }
                  mappings = []
                  thresholds = {
                    mode  = "absolute"
                    steps = [{ color = "green", value = null }]
                  }
                  unit = "bytes"
                }
                overrides = []
              }
              gridPos = { h = 8, w = 12, x = 12, y = 28 }
              id      = 9
              options = {
                legend  = { calcs = ["mean", "max"], displayMode = "table", placement = "bottom", showLegend = true }
                tooltip = { mode = "single", sort = "none" }
              }
              targets = [
                {
                  datasource   = { type = "prometheus", uid = "$datasource" }
                  expr         = "process_resident_memory_bytes{job=\"tetragon\"}"
                  legendFormat = "{{pod}}"
                  refId        = "A"
                }
              ]
              title = "Tetragon Memory Usage"
              type  = "timeseries"
            }
          ]
          title = "Agent Metrics"
          type  = "row"
        }
      ]
      refresh       = "30s"
      schemaVersion = 38
      style         = "dark"
      tags          = ["tetragon", "security", "ebpf", "cilium"]
      templating = {
        list = [
          {
            current = {
              selected = false
              text     = "Prometheus"
              value    = "prometheus"
            }
            hide        = 0
            includeAll  = false
            label       = "Prometheus"
            multi       = false
            name        = "datasource"
            options     = []
            query       = "prometheus"
            refresh     = 1
            regex       = ""
            skipUrlSync = false
            type        = "datasource"
          },
          {
            current = {
              selected = false
              text     = "Loki"
              value    = "loki"
            }
            hide        = 0
            includeAll  = false
            label       = "Loki"
            multi       = false
            name        = "datasource_loki"
            options     = []
            query       = "loki"
            refresh     = 1
            regex       = ""
            skipUrlSync = false
            type        = "datasource"
          }
        ]
      }
      time = {
        from = "now-1h"
        to   = "now"
      }
      timepicker = {}
      timezone   = "browser"
      title      = "Tetragon Security Observability"
      uid        = "tetragon-security"
      version    = 1
      weekStart  = ""
    })
  }
}
