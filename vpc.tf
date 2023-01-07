provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "db_vpc" {
  name                    = "db-${var.db_name}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_global_address" "db_vpc_private_ip" {
  name          = "db-${var.db_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.db_vpc.id
}

resource "google_service_networking_connection" "db_vpc_private_connection" {
  network                 = google_compute_network.db_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db_vpc_private_ip.name]
}
