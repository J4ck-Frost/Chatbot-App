output "artifact_registry_url" {
  description = "Artifact Registry endpoint (Docker registry URL)"
  value       = module.artifact_registry.repository_url
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
  
}

output "region" {
  description = "GCP Region"
  value       = var.region
  
}

output "app_name" {
  description = "Application Name"
  value       = var.app_name
}

output "database_instance_ip" {
  description = "Database instance private IP"
  value       = module.sql.instance_ip
}

output "database_port" {
  description = "Database port"
  value       = module.sql.database_port
}

output "database_name" {
  description = "Database name"
  value       = module.sql.database_name
}

output "kubernetes_cluster_name" {
  description = "GKE Cluster Name"
  value       = module.gke.cluster_name 
}