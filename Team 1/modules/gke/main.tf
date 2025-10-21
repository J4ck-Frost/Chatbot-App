resource "google_container_cluster" "gke_cluster" {
  name                     = var.cluster_name
  location                 = var.region
  remove_default_node_pool = true
  deletion_protection      = false
  initial_node_count = 1

  network    = var.network
  subnetwork = var.subnetwork

  # COS (Container-Optimized OS)
  node_config {
    image_type = "COS_CONTAINERD"
    disk_type  = "pd-standard"
  }
lifecycle {
    ignore_changes = [node_pool]   
  }
  # Disable autoscaling at cluster level
}

# -------------------------------------------------------------------
# NODE POOL CPU 
# -------------------------------------------------------------------
resource "google_container_node_pool" "cpu_pool" {
  name       = "pool-cpu"
  cluster    = google_container_cluster.gke_cluster.name
  location   = var.region

  node_count = 1   # fixed, autoscaling off

  node_config {
    machine_type = var.cpu_pool_machine_type
    disk_size_gb = var.cpu_pool_disk_size
    image_type   = "COS_CONTAINERD"

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

    service_account = var.service_account
  }

  # Không bật autoscaling
  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

    node_locations = ["asia-southeast1-a"]
  }

# -------------------------------------------------------------------
# NODE POOL GPU 
# -------------------------------------------------------------------
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