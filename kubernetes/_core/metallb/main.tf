resource "helm_release" "metallb" {
  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  namespace        = "metallb-system"
  create_namespace = true
  version          = var.metallb_chart_version
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      speaker = {
        frrouting = {
          enabled = true
        }
      }
      ipAddressPools = [
        {
          name      = "default-pool"
          addresses = var.metallb_ip_range
        }
      ]
      bgpPeers = [
        {
          name          = "asa-firewall"
          myASN         = var.metallb_asn
          peerASN       = var.asa_asn
          peerAddress   = var.asa_peer_ip
          holdTime      = "90s"
          keepaliveTime = "30s"
        }
      ]
      bgpAdvertisements = [
        {
          name              = "default"
          ipAddressPools    = ["default-pool"]
          aggregationLength = 32
        }
      ]
    })
  ]
}
