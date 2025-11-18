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
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
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

resource "google_sql_user" "iam_service_account_user" {
  name     = trimsuffix(var.app_service_account_email, ".gserviceaccount.com")
  instance = google_sql_database_instance.instance.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  project  = var.project_id
}