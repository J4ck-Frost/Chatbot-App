
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

variable "service_account_email" {
  description = "The email of the service account to be used by GKE nodes."
  type        = string
}

variable "cpu_pool_machine_type" {
  description = "Machine type for the CPU node pool"
  type        = string
}

variable "cpu_pool_disk_size" {
  description = "Disk size (in GB) for the CPU node pool"
  type        = number
}

variable "enable_gpu_pool" {
  description = "Bật/tắt GPU node pool"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "gke-cluster-dev"
  
}
