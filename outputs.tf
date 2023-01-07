output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "db_vpc_id" {
  value       = google_compute_network.db_vpc.id
  description = "The DB VPC ID"
}

output "db_instance_connection_name" {
  value       = google_sql_database_instance.db_instance.connection_name
  description = "The Database instance connection name"
}

output "default_database" {
  value       = var.db_name
  description = "The default database that will be created."
}

output "db_admin_user_sa" {
  value       = google_service_account.db_admin_service_account.name
  description = "The Database admin service account"
}

output "db_admin_user" {
  value       = trimsuffix(google_service_account.db_admin_service_account.email, ".iam.gserviceaccount.com")
  description = "The Database admin service account email"
}
