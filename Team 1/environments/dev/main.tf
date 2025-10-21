module "vpc" {
  source     = "../../modules/vpc"
  project_id = var.project_id
  region     = var.region
  zone       = var.zone
}

module "artifact_registry" {
  source        = "../../modules/artifact_registry"
  project_id    = var.project_id
  location      = var.region
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

module "sql" {
  source        = "../../modules/sql"
  instance_name = var.instance_name
  region        = var.region
  db_name       = var.db_name
  db_user       = var.db_user
  db_password   = var.db_password
}

module "gke" {
  source          = "../../modules/gke"
  region          = var.region
  cluster_name    = "cluster-1"
  network         = module.vpc.vpc_name
  subnetwork      = module.vpc.subnet_names[0]
  service_account = "terraform-sa@logical-iridium-474603-b4.iam.gserviceaccount.com"
}