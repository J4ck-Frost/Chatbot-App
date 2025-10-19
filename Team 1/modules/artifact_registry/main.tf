resource "google_artifact_registry_repository" "artifact_registry" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = "Artifact Registry for storing Docker images"
  format        = var.format
}