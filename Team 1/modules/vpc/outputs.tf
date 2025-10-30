# VPC Network outputs
output "vpc_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "vpc_self_link" {
  description = "The URI (self link) of the VPC network"
  value       = google_compute_network.vpc_network.self_link
}

# Subnet outputs
output "subnet_names" {
  description = "The names of all subnets created"
  value       = [for subnet in google_compute_subnetwork.subnet : subnet.name]
}

output "subnet_ids" {
  description = "The IDs of all subnets created"
  value       = [for subnet in google_compute_subnetwork.subnet : subnet.id]
}

output "subnet_cidrs" {
  description = "The CIDR ranges of all subnets created"
  value       = [for subnet in google_compute_subnetwork.subnet : subnet.ip_cidr_range]
}

output "subnet_regions" {
  description = "The regions of all subnets created"
  value       = [for subnet in google_compute_subnetwork.subnet : subnet.region]
}

# Map of subnet details for easier reference
output "subnet_details" {
  description = "Map of subnet names to their details"
  value = {
    for name, subnet in google_compute_subnetwork.subnet : name => {
      id            = subnet.id
      name          = subnet.name
      ip_cidr_range = subnet.ip_cidr_range
      region        = subnet.region
      self_link     = subnet.self_link
    }
  }
}