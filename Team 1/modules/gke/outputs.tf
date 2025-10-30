output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.gke_cluster.name
}

output "cluster_location" {
  description = "Cluster region/location"
  value       = google_container_cluster.gke_cluster.location
}

output "cluster_endpoint" {
  description = "GKE control plane endpoint (use gcloud container clusters get-credentials)"
  value       = google_container_cluster.gke_cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA cert (use for kubeconfig)"
  value       = google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate
}

output "workload_pool" {
  description = "Workload Identity pool of the cluster"
  value       = "${var.project_id}.svc.id.goog"
}

output "node_service_account_email" {
  description = "Email of the service account used by node pool (created or provided)"
  value       = local.node_sa_email
}

output "cpu_node_pool_name" {
  description = "CPU node pool name"
  value       = google_container_node_pool.cpu_pool.name
}

# output "gpu_node_pool_name" {
#   description = "GPU node pool name (empty if not created)"
#   value       = try(google_container_node_pool.gpu_pool[0].name, "")
# }