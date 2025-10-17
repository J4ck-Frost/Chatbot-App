variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region cho môi trường dev"
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "Zone cho môi trường dev"
  type        = string
  default     = "asia-southeast1-a"
}
