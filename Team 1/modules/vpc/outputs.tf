# Outputs cho module VPC

# Tên VPC
output "vpc_name" {
  description = "Tên VPC được tạo trong module này"
  value       = google_compute_network.vpc_network.name
}

# Self-link của VPC (đường dẫn API đầy đủ)
output "vpc_self_link" {
  description = "Đường dẫn self-link của VPC"
  value       = google_compute_network.vpc_network.self_link
}

# Danh sách các subnet
output "subnet_names" {
  description = "Tên các subnet được tạo"
  value = [
    google_compute_subnetwork.subnet_1.name,
    google_compute_subnetwork.subnet_2.name,
    google_compute_subnetwork.subnet_3.name
  ]
}

# CIDR của các subnet
output "subnet_cidrs" {
  description = "CIDR range của từng subnet"
  value = [
    google_compute_subnetwork.subnet_1.ip_cidr_range,
    google_compute_subnetwork.subnet_2.ip_cidr_range,
    google_compute_subnetwork.subnet_3.ip_cidr_range
  ]
}

# Region của subnet (đều giống nhau)
output "region" {
  description = "Region của các subnet"
  value       = google_compute_subnetwork.subnet_1.region
}

# ID của VPC để module khác (như GKE, SQL, VM) có thể dùng
output "vpc_id" {
  description = "ID của VPC để dùng ở module khác"
  value       = google_compute_network.vpc_network.id
}

# ID của subnet A (thường dùng để gắn VM/GKE)
output "subnet_a_id" {
  description = "ID của subnet zone A"
  value       = google_compute_subnetwork.subnet_1.id
}
