# Bootstrap module - Sets up initial GCP project configuration and enables required APIs
module "bootstrap" {
  source     = "../../modules/bootstrap"
  project_id = var.project_id
}

# VPC module - Creates Virtual Private Cloud network infrastructure
# Includes VPC network and subnet configuration for resource isolation
module "vpc" {
  source     = "../../modules/vpc"
  project_id = var.project_id
  vpc_name   = var.vpc_name
  subnets    = var.subnets_list
}

# Artifact Registry module - Sets up container registry
# Used for storing and managing container images
module "artifact_registry" {
  source        = "../../modules/artifact_registry"
  project_id    = var.project_id
  location      = var.region
  repository_id = var.repository_id
}

# Cloud Storage module - Creates GCS bucket for application storage
# Used for storing application files, assets, or backups
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

# Cloud SQL module - Sets up PostgreSQL database instance
# Provides managed relational database service
module "sql" {
  source         = "../../modules/sql"
  project_id     = var.project_id
  instance_name  = var.instance_name
  region         = var.region
  db_name        = var.db_name
  db_user        = var.db_user
  db_password    = var.db_password
  vpc_network_id = module.vpc.vpc_self_link
}

# Outputs
output "sql_service_account_email" {
  description = "Service account email for Cloud SQL access"
  value       = module.sql.service_account_email
}

output "sql_instance_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = module.sql.instance_connection_name
}

output "sql_instance_ip" {
  description = "Cloud SQL instance private IP address"
  value       = module.sql.instance_ip
}

output "sql_database_port" {
  description = "PostgreSQL port"
  value       = module.sql.database_port
}

output "sql_database_name" {
  description = "PostgreSQL database name"
  value       = module.sql.database_name
}

output "sql_database_user" {
  description = "PostgreSQL database user"
  value       = module.sql.database_user
}

# GKE (Google Kubernetes Engine) module - Creates managed Kubernetes cluster
# Used for container orchestration and application deployment
module "gke" {
  source          = "../../modules/gke"
  project_id      = var.project_id
  region          = var.region
  cluster_name    = var.cluster_name
  network         = module.vpc.vpc_name
  subnetwork      = module.vpc.subnet_names[0]
  service_account = var.service_account_email

  cpu_pool_machine_type = var.cpu_pool_machine_type
  cpu_pool_disk_size    = var.cpu_pool_disk_size

  # enable_gpu_pool = var.enable_gpu_pool
}

