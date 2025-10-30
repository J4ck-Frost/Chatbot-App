resource "google_project_service" "enable_apis" {
  for_each = toset([
    # Compute Engine API - Required for creating VMs, disks, networks, and other compute resources
    "compute.googleapis.com",
    
    # Artifact Registry API - For storing and managing container images and other artifacts
    "artifactregistry.googleapis.com",
    
    # Identity and Access Management (IAM) API - For managing permissions and service accounts
    "iam.googleapis.com",
    
    # Cloud SQL Admin API - For managing Cloud SQL database instances
    "sqladmin.googleapis.com",
    
    # Service Networking API - Required for VPC network peering with managed services
    "servicenetworking.googleapis.com",
    
    # Cloud Resource Manager API - For managing GCP project resources and hierarchy
    "cloudresourcemanager.googleapis.com",
  ])

  project = var.project_id
  service = each.key

  # When the API is destroyed, don't disable it in the project
  disable_on_destroy = false
}