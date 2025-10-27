variable "bucket_name" {
  type        = string
  description = "Bucket name (must be globally unique)"
}

variable "project_id" {
  type        = string
  description = "GCP project id"
}

variable "location" {
  type        = string
  default     = "ASIA"
  description = "Bucket location/region"
}

variable "storage_class" {
  type    = string
  default = "STANDARD"
}

variable "versioning_enabled" {
  type    = bool
  default = false
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "If true, destroy bucket even if non-empty"
}

variable "uniform_bucket_level_access" {
  type    = bool
  default = true
}

variable "lifecycle_rules" {
  type        = list(any)
  default     = []
  description = "List of lifecycle_rule blocks (raw structure)"
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "iam_bindings" {
  type = list(object({
    role    = string
    members = list(string)
  }))
  default     = []
  description = "Bucket IAM bindings - list of { role = string, members = [\"user:..., serviceAccount:...\", ...] }"
}