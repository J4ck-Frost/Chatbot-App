module "vpc" {
  source = "../../modules/vpc"

  vpc_name    = "dev-vpc"
  region      = var.region
  subnet_cidr = "10.0.0.0/24"
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