variable "region" {
  description = "Region for GKE cluster"
  type        = string
  default     = "asia-southeast1"
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "cluster1"
}

variable "network" {
  description = "VPC network name or ID"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name or ID"
  type        = string
}

variable "service_account" {
  description = "Service account email for node pool"
  type        = string
}

variable "cpu_pool_machine_type" {
  description = "Machine type for the CPU node pool"
  type        = string
  default     = "e2-micro"
}

variable "cpu_pool_disk_size" {
  description = "Disk size (in GB) for the CPU node pool"
  type        = number
  default     = 15
}

variable "enable_gpu_pool" {
  description = "Bật/tắt GPU node pool"
  type        = bool
  default     = false
}

