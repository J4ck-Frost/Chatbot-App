output "artifact_registry_url" {
  description = "Artifact Registry endpoint (Docker registry URL)"
  value       = module.artifact_registry.repository_url
}
