# 1. Create VPC Network
# This resource creates a Virtual Private Cloud network with custom subnet mode
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name                # Name of the VPC network
  auto_create_subnetworks = false                      # Disable auto subnet creation - we'll create them manually
  mtu                     = 1460                       # Maximum Transmission Unit in bytes
  project                 = var.project_id             # GCP project ID where VPC will be created
}

# 2. Create Subnets
# Creates multiple subnets using for_each to iterate through subnet configurations
resource "google_compute_subnetwork" "subnet" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }  # Convert subnet list to map for iteration

  name          = each.value.name                     # Subnet name from configuration
  ip_cidr_range = each.value.ip_cidr_range           # IP range in CIDR notation (e.g., "10.0.0.0/24")
  region        = each.value.region                   # GCP region where subnet will be created
  network       = google_compute_network.vpc_network.id  # Reference to parent VPC network
  project       = var.project_id                      # GCP project ID
  private_ip_google_access = true                     # Enable Private Google Access for this subnet
}

# 3. Create Firewall Rules
# Sets up basic firewall rules for SSH and HTTP access
resource "google_compute_firewall" "allow_ssh_http" {
  name    = "allow-ssh-http"                          # Name of the firewall rule
  network = google_compute_network.vpc_network.name    # Reference to VPC network
  project = var.project_id                            # GCP project ID

  # Allow TCP traffic for SSH (port 22) and HTTP (port 80)
  allow {
    protocol = "tcp"
    ports    = ["22", "80"]                          # List of ports to allow
  }

  # Allow ICMP (ping) traffic
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]                      # Allow traffic from any IP address
  direction     = "INGRESS"                          # Apply to incoming traffic
}