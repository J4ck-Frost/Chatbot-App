output "cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "cpu_node_pool_name" {
  value = google_container_node_pool.cpu_pool.name
}

output "cpu_node_machine_type" {
  value = google_container_node_pool.cpu_pool.node_config[0].machine_type
}
