variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "region" {
  description = "Cluster region (or location for zonal cluster)"
  type        = string
}

variable "network" {
  description = "VPC network self link or name"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork self link or name"
  type        = string
}

variable "service_account" {
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
  description = "List of IAM roles to grant to the node/service account (artifact pull, storage access, cloudsql client, ...)"
  type        = list(string)
  default     = [
    "roles/artifactregistry.reader",
    "roles/storage.objectViewer",
    "roles/cloudsql.client"
  ]
}

variable "cpu_pool_machine_type" {
  description = "Machine type for CPU node pool"
  type        = string
  default     = "e2-micro"
}

variable "cpu_pool_disk_size" {
  description = "Disk size (GB) for CPU node pool"
  type        = number
  default     = 10
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
  default     = "n1-standard-1"
}

variable "gpu_disk_size" {
  description = "Disk size for GPU nodes"
  type        = number
  default     = 15
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
  default     = ["asia-southeast1-a"]
}