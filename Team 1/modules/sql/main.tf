# Reserve an IP range for private service networking
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.instance_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_network_id
  project       = var.project_id
}

# Enable servicenetworking API
resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}

# Create a private VPC connection for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.servicenetworking]
}

# Create Cloud SQL instance
resource "google_sql_database_instance" "instance" {
  name             = var.instance_name
  region           = var.region
  database_version = "POSTGRES_14"
  project          = var.project_id

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false  # Disable public IP
      private_network                               = var.vpc_network_id  # Use VPC network
      enable_private_path_for_google_cloud_services = true   # Enable private service access
    }
    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false  # Set to true in production
  
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Create database
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.instance.name
  project  = var.project_id
}

# Create user
resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = var.db_password
  project  = var.project_id
}

# Create service account for Cloud SQL access
resource "google_service_account" "cloud_sql_access" {
  account_id   = "cloud-sql-access-${var.instance_name}"
  display_name = "Cloud SQL Access Service Account"
  project      = var.project_id
}

# Grant Cloud SQL Client role to service account
resource "google_project_iam_member" "cloud_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_sql_access.email}"
}

# Create workload identity binding for GKE pods
resource "google_service_account_iam_binding" "workload_identity" {
  service_account_id = google_service_account.cloud_sql_access.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/cloud-sql-proxy]"
  ]
}