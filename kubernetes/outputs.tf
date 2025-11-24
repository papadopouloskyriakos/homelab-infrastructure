output "namespaces" {
  description = "Created namespaces"
  value = {
    production = kubernetes_namespace.production.metadata[0].name
    pihole     = kubernetes_namespace.pihole.metadata[0].name
  }
}

output "pihole_web_service" {
  description = "Pi-hole web interface service"
  value       = "${kubernetes_service.pihole_web.metadata[0].name}.${kubernetes_namespace.pihole.metadata[0].name}.svc.cluster.local"
}

output "pihole_dns_tcp" {
  description = "Pi-hole DNS TCP service"
  value       = kubernetes_service.pihole_dns_tcp.metadata[0].name
}

output "pihole_dns_udp" {
  description = "Pi-hole DNS UDP service"
  value       = kubernetes_service.pihole_dns_udp.metadata[0].name
}

output "pihole_admin_url" {
  description = "Pi-hole admin interface URL"
  value       = "http://pihole.example.net/admin"
}

output "access_instructions" {
  description = "How to access Pi-hole"
  value = <<-EOF
    
    Pi-hole Deployment Complete!
    
    Access Methods:
    
    1. Port Forward (Quick Test):
       kubectl port-forward -n pihole svc/pihole-web 8080:80
       Then visit: http://localhost:8080/admin
    
    2. Ingress (Production):
       Visit: http://pihole.example.net/admin
       (Configure DNS to point to your ingress IP)
    
    3. Get LoadBalancer IP:
       kubectl get svc -n pihole pihole-dns-tcp
       kubectl get svc -n pihole pihole-dns-udp
    
    Login: admin
    Password: [Set via PIHOLE_PASSWORD variable]
    
  EOF
}
