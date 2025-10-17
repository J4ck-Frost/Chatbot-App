variable "project_name" {
  description = "GCP project name"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region cho môi trường dev"
  type        = string
  default     = "asia-southeast1"
}

variable "repository_id" {
  description = "Name of the Artifact Registry repository"
  type        = string
  default     = "team1-ai-repo"
}

variable "zone" {
  description = "Zone cho môi trường dev"
  type        = string
  default     = "asia-southeast1-a"
}
