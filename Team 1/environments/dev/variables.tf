// Variables for environment "dev" used by main.tf modules

variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "project_name" {
  description = "Short project name used for resource naming"
  type        = string
}

variable "region" {
  description = "Primary region for resources (GCP)"
  type        = string
  default     = "asia-southeast1"
}

# VPC / networking
variable "vpc_name" {
  description = "Name of the VPC network to create/use"
  type        = string
  default     = "dev-vpc"
}

variable "subnets_list" {
  description = "List of subnet objects to create in the VPC"
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
  }))
  default = []
}

# GKE cluster
variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "app-cluster"
}

variable "service_account_email" {
  description = "Existing GCP service account email to attach to node pool (leave empty to create one)"
  type        = string
  default     = ""
}

variable "create_node_service_account" {
  description = "If true, module will create a GCP service account to use for node workloads"
  type        = bool
  default     = true
}

variable "node_service_account_id" {
  description = "Account id (local-part) for created GCP service account (no project suffix)"
  type        = string
  default     = "gke-node-sa"
}

variable "node_service_account_roles" {
  description = "List of IAM roles to grant to the node/service account"
  type        = list(string)
  default     = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer"
  ]
}

# CPU node pool
variable "cpu_pool_machine_type" {
  description = "Machine type for CPU node pool"
  type        = string
  default     = "e2-micro"
}

variable "cpu_pool_disk_size" {
  description = "Disk size (GB) for CPU node pool"
  type        = number
}

variable "cpu_node_count" {
  description = "Initial node count for CPU pool"
  type        = number
  default     = 2
}

variable "cpu_node_autoscaling_min" {
  description = "Autoscaling min for CPU pool"
  type        = number
  default     = 1
}

variable "cpu_node_autoscaling_max" {
  description = "Autoscaling max for CPU pool"
  type        = number
  default     = 3
}

variable "node_zones" {
  description = "List of zones for node pool placement"
  type        = list(string)
  default     = []
}

# GPU node pool (optional)
variable "enable_gpu_pool" {
  description = "Enable GPU node pool"
  type        = bool
  default     = false
}

variable "gpu_node_count" {
  description = "Node count for GPU pool"
  type        = number
  default     = 1
}

variable "gpu_machine_type" {
  description = "Machine type for GPU nodes"
  type        = string
  default     = "n1-standard-4"
}

variable "gpu_disk_size" {
  description = "Disk size (GB) for GPU nodes"
  type        = number
}

variable "gpu_type" {
  description = "GPU type"
  type        = string
  default     = "nvidia-tesla-t4"
}

variable "gpu_count" {
  description = "Number of GPUs per GPU node"
  type        = number
  default     = 1
}

variable "gpu_node_zones" {
  description = "Zones for GPU node pool"
  type        = list(string)
  default     = []
}

# Artifact Registry
variable "repository_id" {
  description = "Artifact Registry repository id (name)"
  type        = string
  default     = "app-repo"
}

# Cloud Storage / Bucket
variable "bucket_name" {
  description = "Optional explicit bucket name (if omitted module may build one)"
  type        = string
  default     = ""
}

# Cloud SQL
variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "sql-instance"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "db_name"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "db_user"
}

variable "db_password" {
  description = "Database password (sensitive)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "postgres-test-app"
}