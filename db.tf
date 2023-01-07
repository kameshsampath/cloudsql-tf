resource "google_sql_database" "db" {
  name     = var.db_name
  instance = google_sql_database_instance.db_instance.name
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "db_instance" {
  name             = "${var.db_name}-${random_id.db_name_suffix.hex}"
  region           = var.region
  database_version = var.db_version

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.db_vpc.id
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }

  depends_on = [
    google_service_networking_connection.db_vpc_private_connection
  ]

  # delete the instance via terraform
  deletion_protection = false
}

resource "google_service_account" "db_admin_service_account" {
  account_id   = "dbadmin-${random_id.db_name_suffix.hex}"
  display_name = "dbadmin-${random_id.db_name_suffix.hex}"
  description  = "The Database Administrator Service Account"
}

resource "google_project_iam_binding" "dbadmin-roles" {
  for_each = toset(["roles/cloudsql.instanceUser", "roles/cloudsql.client"])
  project  = var.project_id
  role     = each.key
  members = [
    google_service_account.db_admin_service_account.member,
  ]
}

resource "google_project_iam_binding" "dbadmin-sql-client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  members = [
    google_service_account.db_admin_service_account.member,
  ]
}

resource "google_sql_user" "db_admin_user" {
  # due to username length in DB we need to trim `.gserviceaccount.com` suffix
  # https://cloud.google.com/sql/docs/postgres/add-manage-iam-users#gcloud_1
  name            = trimsuffix(google_service_account.db_admin_service_account.email, ".gserviceaccount.com")
  instance        = google_sql_database_instance.db_instance.name
  type            = "CLOUD_IAM_SERVICE_ACCOUNT"
  deletion_policy = "ABANDON"
}
