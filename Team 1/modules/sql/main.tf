# Cloud SQL PostgreSQL - Private IP Direct Connection

# Enable required APIs
resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

# Reserve global internal address range for private services
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.instance_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_network_id
  
  depends_on = [google_project_service.servicenetworking]
}

# Private connection to Google services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Cloud SQL PostgreSQL instance with private IP
resource "google_sql_database_instance" "postgres" {
  name             = var.instance_name
  database_version = "POSTGRES_13"
  region           = var.region
  deletion_protection = false

  settings {
    tier = var.tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network_id
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    backup_configuration {
      enabled = true
      start_time = "10:00"
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# PostgreSQL database
resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
}

# PostgreSQL user
resource "google_sql_user" "default" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

# Service Account for Cloud SQL access
resource "google_service_account" "sql_client" {
  account_id   = "${var.instance_name}-client"
  display_name = "Cloud SQL Client Service Account"
  description  = "Service account for GKE pods to connect to Cloud SQL"
}

# IAM role for Cloud SQL client
resource "google_project_iam_member" "sql_client_role" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.sql_client.email}"
}

# Service Account Key for Cloud SQL Proxy
resource "google_service_account_key" "sql_client_key" {
  service_account_id = google_service_account.sql_client.name
}