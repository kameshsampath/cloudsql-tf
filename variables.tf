variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "the region or zone where the cluster will be created"
  default     = "asia-south1"
}

variable "cluster_name" {
  description = "the gke cluster name"
  default     = "my-demos"
}

variable "db_name" {
  description = "the Cloud SQL Database"
  default     = "my-db"
}

# https://cloud.google.com/sql/docs/db-versions
variable "db_version" {
  description = "the database version to use"
  default     = "POSTGRES_14"
}

variable "db_tier" {
  description = "the database tier"
  default     = "db-f1-micro"
}

variable "db_default_database_name" {
  description = "the default database that will be created"
  default     = "demodb"
}
