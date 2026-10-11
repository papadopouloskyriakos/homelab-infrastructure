# Shop public service availability (MESHSAT-1535). Read-only probes run by the
# existing NL blackbox exporter, through public DNS and the edge. /readyz includes
# the ordering database while ordering is OFF; no checkout or subscription is made.
resource "kubernetes_manifest" "REDACTED_86c5dce5" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "ScrapeConfig"
    metadata = {
      name      = "meshsat-shop-public"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "release"                   = "monitoring"
      }
    }
    spec = {
      jobName        = "meshsat-shop-public"
      scrapeInterval = "60s"
      scrapeTimeout  = "30s"
      metricsPath    = "/probe"
      params         = { module = ["http_2xx"] }
      staticConfigs = [{
        targets = [
          "https://shop.meshsat.net/",
          "https://order.meshsat.net/readyz",
          "https://list.meshsat.net/api/public/lists",
        ]
        labels = {
          service = "meshsat-shop"
          env     = "production"
          leg     = "https"
        }
      }]
      relabelings = [
        { sourceLabels = ["__address__"], targetLabel = "__param_target" },
        { sourceLabels = ["__param_target"], targetLabel = "instance" },
        { targetLabel = "__address__", replacement = "10.0.X.X:9115" },
      ]
    }
  }
}
