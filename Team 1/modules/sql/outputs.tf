output "instance_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.connection_name
}

output "instance_ip" {
  description = "The private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "database_port" {
  description = "PostgreSQL port"
  value       = 5432
}

output "database_name" {
  description = "The name of the database"
  value       = google_sql_database.default.name
}

output "database_user" {
  description = "The database user name"
  value       = google_sql_user.default.name
}

output "service_account_email" {
  description = "Email of the service account for Cloud SQL access"
  value       = google_service_account.sql_client.email
}

output "service_account_key" {
  description = "The service account key for Cloud SQL Proxy"
  value       = google_service_account_key.sql_client_key.private_key
  sensitive   = true
}
