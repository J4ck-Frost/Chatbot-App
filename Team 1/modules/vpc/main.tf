terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {

  project = "logical-iridium-474603-b4"
  region  = var.region
}

# ------------------------
# 1. Tạo VPC
# ------------------------
resource "google_compute_network" "vpc_network" {
  name                    = "second-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  project                 = var.project_id
}

# ------------------------
# 2. Tạo subnet cho từng zone
# ------------------------
resource "google_compute_subnetwork" "subnet_a" {
  name          = "subnet-asia-southeast1-a"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
}

resource "google_compute_subnetwork" "subnet_b" {
  name          = "subnet-asia-southeast1-b"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
}

resource "google_compute_subnetwork" "subnet_c" {
  name          = "subnet-asia-southeast1-c"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
}

# ------------------------
# 3. Tạo firewall rule
# ------------------------
resource "google_compute_firewall" "allow_ssh_http" {
  name    = "allow-ssh-http"
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
}



