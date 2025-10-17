variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region để tạo VPC"
  type        = string
}

variable "zone" {
  description = "Zone để tạo VM"
  type        = string
  default     = "asia-southeast1-a"
}
