output "instance_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.connection_name
}

output "instance_ip" {
  description = "The private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.private_ip_address
}

output "database_port" {
  description = "PostgreSQL port"
  value       = 5432
}

output "database_name" {
  description = "The name of the database"
  value       = google_sql_database.database.name
}

output "database_user" {
  description = "The database user name"
  value       = google_sql_user.user.name
}

output "service_account_email" {
  description = "Email of the service account for Cloud SQL access"
  value       = google_service_account.cloud_sql_access.email
}
