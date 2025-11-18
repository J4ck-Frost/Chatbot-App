
data "google_client_config" "default" {}

provider "kubernetes" {
  # Lấy trực tiếp từ output của module GKE
  host  = "https://${module.gke.cluster_endpoint}" 
  token = data.google_client_config.default.access_token
   
  cluster_ca_certificate = base64decode(
    # Lấy trực tiếp từ output của module GKE
    module.gke.cluster_ca_certificate
  )
}

resource "google_service_account" "app-gsa" {
  account_id   = "${var.instance_name}-gsa"
  display_name = "GSA for ${var.instance_name}-gsa"
  project      = var.project_id
}

resource "kubernetes_service_account" "app-ksa" {
  provider = kubernetes

  metadata {
    name      = "${var.instance_name}-ksa"
    namespace = "default"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.app-gsa.email
    }
  }

  depends_on = [
    module.gke.cluster_name,
  ]
}

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.app-gsa.name

  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_service_account.app-ksa.metadata[0].namespace}/${kubernetes_service_account.app-ksa.metadata[0].name}]"

  depends_on = [
    kubernetes_service_account.app-ksa,
    google_service_account.app-gsa
  ]
}

resource "google_project_iam_binding" "cloud_sql_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  members = [
    google_service_account.app-gsa.member
  ]

  depends_on = [module.sql.instance_connection_name]
}

resource "google_project_iam_binding" "cloud_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  members = [
    google_service_account.app-gsa.member
  ]

  depends_on = [module.sql.instance_connection_name]
}

resource "google_storage_bucket_iam_member" "gcs_access_binding" {
  bucket  = module.app_bucket.bucket_name
  role    = "roles/storage.objectAdmin"
  member  = google_service_account.app-gsa.member

  depends_on = [
    module.app_bucket,
    google_service_account.app-gsa
  ]
}


