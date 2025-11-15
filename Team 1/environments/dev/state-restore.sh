# VPC Network (was already imported earlier)
terraform import module.vpc.google_compute_network.vpc_network projects/devopts-k2-advance/global/networks/dev-vpc

# Subnet
terraform import 'module.vpc.google_compute_subnetwork.subnet["subnet-1"]' projects/devopts-k2-advance/regions/asia-southeast1/subnetworks/subnet-1

# Firewall (was already imported earlier)
terraform import module.vpc.google_compute_firewall.allow_ssh_http projects/devopts-k2-advance/global/firewalls/allow-ssh-http

# GKE Node Service Account
terraform import module.gke.google_service_account.node_sa[0] projects/devopts-k2-advance/serviceAccounts/dev-postgres-client@devopts-k2-advance.iam.gserviceaccount.com

# SQL Cloud SQL Access Service Account
terraform import module.sql.google_service_account.cloud_sql_access projects/devopts-k2-advance/serviceAccounts/cloud-sql-access-dev-postgres@devopts-k2-advance.iam.gserviceaccount.com

# App GSA Service Account
terraform import google_service_account.app-gsa projects/devopts-k2-advance/serviceAccounts/dev-postgres-app-gsa@devopts-k2-advance.iam.gserviceaccount.com

# GKE Cluster (was already imported earlier)
terraform import module.gke.google_container_cluster.gke_cluster projects/devopts-k2-advance/locations/asia-southeast1-a/clusters/app-cluster

# CPU Node Pool (was already imported earlier)
terraform import module.gke.google_container_node_pool.cpu_pool projects/devopts-k2-advance/locations/asia-southeast1-a/clusters/app-cluster/nodePools/cpu-pool

# GPU Node Pool (was already imported earlier)
terraform import module.gke.google_container_node_pool.gpu_pool[0] projects/devopts-k2-advance/locations/asia-southeast1-a/clusters/app-cluster/nodePools/gpu-pool

# Artifact Registry Repository
terraform import module.artifact_registry.google_artifact_registry_repository.artifact_registry projects/devopts-k2-advance/locations/asia-southeast1/repositories/app-repo

# GCS Bucket
terraform import module.app_bucket.google_storage_bucket.this devopts-k2-advance_cloudbuild

# SQL Database Instance (was already imported earlier)
terraform import module.sql.google_sql_database_instance.instance dev-postgres

# SQL Database (was already imported earlier)
terraform import module.sql.google_sql_database.database projects/devopts-k2-advance/instances/dev-postgres/databases/postgres-db

# SQL User (was already imported earlier)
terraform import module.sql.google_sql_user.user postgres//dev-postgres

# Global Address for Private IP
terraform import module.sql.google_compute_global_address.private_ip_address projects/devopts-k2-advance/global/addresses/dev-postgres-private-ip

# Service Networking Connection
terraform import module.sql.google_service_networking_connection.private_vpc_connection "projects/devopts-k2-advance/global/networks/dev-vpc:servicenetworking.googleapis.com"

# GKE Node Service Account IAM Roles
terraform import 'module.gke.google_project_iam_member.node_sa_roles["roles/artifactregistry.reader"]' "devopts-k2-advance roles/artifactregistry.reader serviceAccount:dev-postgres-client@devopts-k2-advance.iam.gserviceaccount.com"

terraform import 'module.gke.google_project_iam_member.node_sa_roles["roles/logging.logWriter"]' "devopts-k2-advance roles/logging.logWriter serviceAccount:dev-postgres-client@devopts-k2-advance.iam.gserviceaccount.com"

terraform import 'module.gke.google_project_iam_member.node_sa_roles["roles/monitoring.metricWriter"]' "devopts-k2-advance roles/monitoring.metricWriter serviceAccount:dev-postgres-client@devopts-k2-advance.iam.gserviceaccount.com"

terraform import 'module.gke.google_project_iam_member.node_sa_roles["roles/stackdriver.resourceMetadata.writer"]' "devopts-k2-advance roles/stackdriver.resourceMetadata.writer serviceAccount:dev-postgres-client@devopts-k2-advance.iam.gserviceaccount.com"

terraform import 'module.gke.google_project_iam_member.node_sa_roles["roles/storage.objectViewer"]' "devopts-k2-advance roles/storage.objectViewer serviceAccount:dev-postgres-client@devopts-k2-advance.iam.gserviceaccount.com"

# Cloud SQL Client IAM Role
terraform import module.sql.google_project_iam_member.cloud_sql_client "devopts-k2-advance roles/cloudsql.client serviceAccount:cloud-sql-access-dev-postgres@devopts-k2-advance.iam.gserviceaccount.com"