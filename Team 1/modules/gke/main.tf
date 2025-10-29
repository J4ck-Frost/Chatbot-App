
# Enable required APIs

resource "google_project_service" "container_api" {
  service = "container.googleapis.com"
  disable_on_destroy = false
}

# GKE Cluster (regional, multi-zonal)

resource "google_container_cluster" "gke_cluster" {
  name                     = var.cluster_name
  location                 = var.region                      # asia-southeast1
  remove_default_node_pool = true
  deletion_protection      = false
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  depends_on = [google_project_service.container_api]

  # Bật Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Cấu hình mặc định cho control plane
  node_config {
    image_type = "COS_CONTAINERD"
    disk_type  = "pd-standard"
  }

  lifecycle {
    ignore_changes = [node_pool]
  }
}

# CPU Node Pool (multi-zone, 1 node/zone)

resource "google_container_node_pool" "cpu_pool" {
  name     = "pool-cpu"
  cluster  = google_container_cluster.gke_cluster.name
  location = var.region                                    # asia-southeast1

  node_count = 2                                      # tổng 2 node, mỗi zone 1 node

  node_config {
    machine_type    = var.cpu_pool_machine_type
    disk_size_gb    = var.cpu_pool_disk_size
    image_type      = "COS_CONTAINERD"
    service_account = var.service_account

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      pool_type = "cpu"
    }

    tags = ["cpu-node"]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  autoscaling {
    min_node_count = 2
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Triển khai node ở cả 2 zone
  node_locations = var.node_zones

}

# NODE POOL GPU 

# resource "google_container_node_pool" "gpu_pool" {
#   count      = var.enable_gpu_pool ? 1 : 0 # cho phép bật/tắt
#   name       = "pool-gpu"
#   cluster    = google_container_cluster.gke_cluster.name
#   location   = var.region
#   node_count = 1

#   node_config {
#     machine_type = "n1-standard-1"          # nhỏ nhất có thể gắn GPU
#     disk_size_gb = 15
#     image_type   = "COS_CONTAINERD"

#     guest_accelerator {
#       type  = "nvidia-tesla-t4"             # GPU rẻ nhất
#       count = 1
#     }

#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]

#     labels = {
#       pool_type = "gpu"
#     }

#     tags = ["gpu-node"]

#     metadata = {
#       disable-legacy-endpoints = "true"
#     }

#     service_account = var.service_account
#   }

#   management {
#     auto_repair  = true
#     auto_upgrade = true
#   }

#   node_locations = ["asia-southeast1-a"]

#   lifecycle {
#   ignore_changes = [
#     node_config[0].guest_accelerator
#   ]
# }


# }