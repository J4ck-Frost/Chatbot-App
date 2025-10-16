# cấu hình provider & backend chung
provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  required_version = ">= 1.6.0"

  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "env/dev"
  }
}
