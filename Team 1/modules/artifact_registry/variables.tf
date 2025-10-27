variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "location" {
  description = "Region to create artifact registry"
  type        = string
}

variable "repository_id" {
  description = "Name of the Artifact Registry repository"
  type = string
}

variable "format" {
  description = "Repository Format"
  type = string
  default = "DOCKER"
}