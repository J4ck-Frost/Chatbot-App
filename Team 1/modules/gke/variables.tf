variable "region" {
  description = "Region for GKE cluster"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
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
