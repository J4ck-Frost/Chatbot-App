# GKE Cluster 

resource "google_container_cluster" "gke_cluster" {
  name                     = var.cluster_name
  location                 = var.node_zones[0]                      
  remove_default_node_pool = true
  deletion_protection      = false
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  # Bật Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  lifecycle {
    ignore_changes = [node_pool]
  }
}

# Optional: create a dedicated GCP service account for GKE node workloads
resource "google_service_account" "node_sa" {
  count        = var.create_node_service_account ? 1 : 0
  account_id   = var.node_service_account_id
  display_name = "GKE node/service workload service account"
  project      = var.project_id
}

# Determine the service account email used on nodes (either provided or created)
locals {
  node_sa_email = length(var.service_account) > 0 ? var.service_account : (
    var.create_node_service_account ? google_service_account.node_sa[0].email : ""
  )
}

# Grant IAM roles to node/service account so workloads can access required services
resource "google_project_iam_member" "node_sa_roles" {
  for_each = toset(var.node_service_account_roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${local.node_sa_email}"
}

# CPU Node Pool (multi-zone)
resource "google_container_node_pool" "cpu_pool" {
  name     = "cpu-pool"
  cluster  = google_container_cluster.gke_cluster.name
  location = google_container_cluster.gke_cluster.location
  node_count = var.cpu_node_count
  node_locations = var.node_zones

  node_config {
    machine_type    = var.cpu_pool_machine_type
    disk_size_gb    = var.cpu_pool_disk_size
    image_type      = "COS_CONTAINERD"
    service_account = local.node_sa_email != "" ? local.node_sa_email : var.service_account

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
    min_node_count = var.cpu_node_autoscaling_min
    max_node_count = var.cpu_node_autoscaling_max
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Optional GPU node pool (kept commented in original; enable via var.enable_gpu_pool)
# resource "google_container_node_pool" "gpu_pool" {
#   count    = var.enable_gpu_pool ? 1 : 0
#   name     = "pool-gpu"
#   cluster  = google_container_cluster.gke_cluster.name
#   location = var.region
#   node_count = var.gpu_node_count

#   node_config {
#     machine_type = var.gpu_machine_type
#     disk_size_gb = var.gpu_disk_size
#     image_type   = "COS_CONTAINERD"

#     guest_accelerator {
#       type  = var.gpu_type
#       count = var.gpu_count
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

#     service_account = local.node_sa_email != "" ? local.node_sa_email : var.service_account
#   }

#   management {
#     auto_repair  = true
#     auto_upgrade = true
#   }

#   node_locations = var.gpu_node_zones

#   lifecycle {
#     ignore_changes = [
#       node_config[0].guest_accelerator
#     ]
#   }
# }