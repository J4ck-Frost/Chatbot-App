variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "vpc_network_id" {
  description = "VPC network self-link for private service access"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "k8s_namespace" {
  description = "Kubernetes namespace where Cloud SQL Proxy will run"
  type        = string
  default     = "default"
}

variable "app_service_account_email" {
  description = "Email of the GCP service account used by the application"
  type        = string
}