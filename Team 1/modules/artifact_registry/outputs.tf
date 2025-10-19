output "repository_url" {
  description = "Docker registry url"
  value       = "https://${var.location}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}