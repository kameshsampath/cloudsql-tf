data "google_compute_default_service_account" "default" {
}

# This is used to set local variable google_zone.
data "google_compute_zones" "available" {
  region = var.region
}

resource "random_shuffle" "az" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

locals {
  google_zone = random_shuffle.az.result[0]
}

# Subnet
resource "google_compute_subnetwork" "bastion_subnet" {
  name          = "${var.db_name}-bastion-subnet"
  region        = var.region
  network       = google_compute_network.db_vpc.name
  ip_cidr_range = "10.128.0.0/20"
}

resource "google_compute_firewall" "bastion_ssh" {
  name    = "bastion-allow-ssh"
  network = google_compute_network.db_vpc.name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}

resource "google_compute_instance" "sql_client_vm" {
  name         = "sql-client"
  machine_type = "e2-medium"
  zone         = local.google_zone

  tags = ["sql-client", "bastion"]

  boot_disk {
    initialize_params {
      # gcloud compute images list
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.db_vpc.id
    subnetwork = google_compute_subnetwork.bastion_subnet.id

    access_config {
      // Ephemeral public IP
    }
  }


  metadata_startup_script = <<EOF
#! /bin/bash
apt-get update
apt-get install -y  postgresql-client
apt-get install -y wget
wget -q https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /bin/cloud_sql_proxy
chmod +x /bin/cloud_sql_proxy
EOF

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
}