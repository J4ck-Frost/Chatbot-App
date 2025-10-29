provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file("D:/Terraform/terraform-key.json")
}
