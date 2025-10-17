module "vpc" {

  source     = "../../modules/vpc"
  project_id = var.project_id
  region     = var.region
  zone       = var.zone

}

module "artifact_registry" {
  source = "../../modules/artifact_registry"
  project_id = var.project_id
  location = var.region
  repository_id = var.repository_id
}

module "app_bucket" {
  source                      = "../../modules/storage"
  bucket_name                 = "${var.project_name}-app-bucket-dev"
  project_id                  = var.project_id
  location                    = var.region
  storage_class               = "STANDARD"
  versioning_enabled          = true
  force_destroy               = false
  uniform_bucket_level_access = true

  labels = {
    env  = "dev"
    team = "team-1"
  }

  iam_bindings = [
    # {
    #   role    = "roles/storage.objectViewer"
    #   members = ["user:ducquank52t1@gmail.com"]
    # }
  ]
}