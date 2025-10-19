
variable "db_name" {
  description = "The name of the default database."
  type        = string
}

variable "db_user" {
  description = "The name of the default user."
  type        = string
}

variable "db_password" {
  description = "The password for the default user."
  type        = string
  sensitive   = true
}

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

variable "instance_name" {
  description = "The name of the Cloud SQL instance."
  type        = string
}
