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
  region     = var.region
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

# Cloud Storage module - Creates GCS bucket for application storage
# Used for storing application files, assets, or backups
module "app_bucket" {
  source              = "../../modules/storage"
  bucket_name         = "${var.bucket_name}-${var.project_id}"
  project_id          = var.project_id
  location            = var.region
  storage_class       = "STANDARD"
  versioning_enabled  = true

  labels = {
    env  = "dev"
    team = "team-1"
  }
}

# Cloud SQL module - Sets up PostgreSQL database instance
# Provides managed relational database service (using Private IP as chosen)
module "sql" {
  source         = "../../modules/sql"

  # required inputs
  project_id     = var.project_id
  instance_name  = var.instance_name
  region         = var.region

  # database details
  db_name        = var.db_name
  db_user        = var.db_user
  db_password    = var.db_password

  # IMPORTANT: module expects variable vpc_network_id (self_link of VPC)
  vpc_network_id = module.vpc.vpc_self_link

  # Kubernetes namespace where pods will run (for Workload Identity bindings if used)
  k8s_namespace  = "default"  # or your application namespace

  app_service_account_email = google_service_account.app-gsa.email
}

# Create test app .env file
resource "local_file" "app_env" {
  filename = "${path.module}/../../test-app/.env"
  content  = <<EOT
    PORT=3000
    DB_HOST=${module.sql.instance_ip}
    DB_PORT=${module.sql.database_port}
    DB_NAME=${module.sql.database_name}
    DB_IAM_USER=${trimsuffix(google_service_account.app-gsa.email, ".gserviceaccount.com")}
    GCS_BUCKET_NAME=${module.app_bucket.bucket_name}
    PROJECT_ID=${var.project_id}
    REGION=${var.region}
    INSTANCE_NAME=${var.instance_name}
    DB_SSL_MODE=disable
  EOT
}

# Generate Helm values.yaml dynamically
resource "local_file" "helm_values" {
  filename = "${path.module}/../../helms/test-app/values-dev.yaml"
  content  = <<EOT
    replicaCount: 1

    app:
      name: ${var.app_name}
      image:
        repository: ${replace(module.artifact_registry.repository_url, "https://", "")}/${var.app_name}
        tag: latest
        pullPolicy: Always
      containerPort: 3000
      livenessProbe:
        path: /
        port: 3000
        initialDelaySeconds: 45
        periodSeconds: 10

    cloudSqlProxy:
      image:
        repository: gcr.io/cloudsql-docker/gce-proxy
        tag: "1.37.10"
      projectId: ${var.project_id}
      region: ${var.region}
      instanceName: ${var.instance_name}
      resources:
        limits:
          cpu: 100m
          memory: 128Mi

    serviceAccountName: ${kubernetes_service_account.app-ksa.metadata[0].name}

    service:
      name: ${var.app_name}-service
      type: LoadBalancer
      port: 80
  EOT
}

# # End of environment configuration