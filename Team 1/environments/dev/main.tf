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

# GKE (Google Kubernetes Engine) module - Creates managed Kubernetes cluster
# Must be created before artifact registry / storage so we can use node/service account outputs
module "gke" {
  source          = "../../modules/gke"
  project_id      = var.project_id
  region          = var.region
  cluster_name    = var.cluster_name

  # Network - pass VPC and subnetwork created by vpc module
  network         = module.vpc.vpc_self_link        # can be self_link or name depending on module
  subnetwork      = module.vpc.subnet_names[0]     # use first subnet name (or adjust index)

  # Service account handling (either provide existing SA email or let module create one)
  service_account              = var.service_account_email
  create_node_service_account  = var.create_node_service_account
  node_service_account_id      = var.node_service_account_id
  node_service_account_roles   = var.node_service_account_roles

  # Node pool configuration
  cpu_pool_machine_type = var.cpu_pool_machine_type
  cpu_pool_disk_size    = var.cpu_pool_disk_size
  cpu_node_count        = var.cpu_node_count
  cpu_node_autoscaling_min = var.cpu_node_autoscaling_min
  cpu_node_autoscaling_max = var.cpu_node_autoscaling_max
  node_zones            = var.node_zones

  enable_gpu_pool = var.enable_gpu_pool
  gpu_node_count  = var.gpu_node_count
  gpu_machine_type = var.gpu_machine_type
  gpu_disk_size   = var.gpu_disk_size
  gpu_type        = var.gpu_type
  gpu_count       = var.gpu_count
  gpu_node_zones  = var.gpu_node_zones
}

# Artifact Registry module - Sets up container registry
# Used for storing and managing container images
module "artifact_registry" {
  source              = "../../modules/artifact_registry"
  project_id          = var.project_id
  location            = var.region
  repository_id       = var.repository_id

  # Use node/service account email from GKE module to grant pull permissions
  gke_service_account = module.gke.node_service_account_email
}

# # Cloud Storage module - Creates GCS bucket for application storage
# # Used for storing application files, assets, or backups
# module "app_bucket" {
#   source              = "../../modules/storage"
#   bucket_name         = "${var.project_name}-app-bucket-dev"
#   project_id          = var.project_id
#   location            = var.region
#   storage_class       = "STANDARD"
#   versioning_enabled  = true

#   # Allow GKE node/service account to access bucket
#   gke_service_account = module.gke.node_service_account_email

#   labels = {
#     env  = "dev"
#     team = "team-1"
#   }
# }

# # Cloud SQL module - Sets up PostgreSQL database instance
# # Provides managed relational database service (using Private IP as chosen)
# module "sql" {
#   source         = "../../modules/sql"

#   # required inputs
#   project_id     = var.project_id
#   instance_name  = var.instance_name
#   region         = var.region

#   # database details
#   db_name        = var.db_name
#   db_user        = var.db_user
#   db_password    = var.db_password

#   # IMPORTANT: module expects variable vpc_network_id (self_link of VPC)
#   vpc_network_id = module.vpc.vpc_self_link

#   # Kubernetes namespace where pods will run (for Workload Identity bindings if used)
#   k8s_namespace  = "default"  # or your application namespace
# }

# # End of environment configuration