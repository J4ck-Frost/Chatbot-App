variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "Location for the artifact registry"
  type        = string
}

variable "repository_id" {
  description = "ID of the repository"
  type        = string
}

variable "format" {
  description = "Format of the repository"
  type        = string
  default     = "DOCKER"
}

variable "gke_service_account" {
  description = "GKE service account email that needs access to pull images"
  type        = string
}