***REMOVED***
# SeaweedFS Outputs
***REMOVED***

output "namespace" {
  description = "SeaweedFS namespace"
  value       = REDACTED_46569c16.seaweedfs.metadata[0].name
}

output "s3_endpoint" {
  description = "S3-compatible API endpoint (internal)"
  value       = "http://seaweedfs-filer.seaweedfs.svc.cluster.local:8333"
}

output "filer_endpoint" {
  description = "Filer HTTP endpoint (internal)"
  value       = "http://seaweedfs-filer.seaweedfs.svc.cluster.local:8888"
}

output "master_endpoint" {
  description = "Master HTTP endpoint (internal)"
  value       = "http://seaweedfs-master.seaweedfs.svc.cluster.local:9333"
}
