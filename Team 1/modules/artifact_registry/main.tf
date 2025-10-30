# Create Artifact Registry repository
resource "google_artifact_registry_repository" "artifact_registry" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = "Artifact Registry for storing Docker images"
  format        = var.format
}

# Grant permissions to GKE service account to pull images
resource "google_artifact_registry_repository_iam_member" "gke_pull" {
  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.artifact_registry.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.gke_service_account}"
}