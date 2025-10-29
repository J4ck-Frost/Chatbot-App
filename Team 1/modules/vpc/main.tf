terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

# 1. Tạo VPC

resource "google_compute_network" "vpc_network" {
  name                    = "second-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  project                 = var.project_id
}

# 2. Tạo subnet cho từng zone

resource "google_compute_subnetwork" "subnet_1" {
  name          = "subnet-1"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = "subnet-2"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_3" {
  name          = "subnet-3"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
  private_ip_google_access = true
}

# 3. Tạo firewall rule

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



