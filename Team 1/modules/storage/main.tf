# Cloud Storage bucket configuration
resource "google_storage_bucket" "this" {
  name                        = var.bucket_name
  project                     = var.project_id
  location                    = var.location
  storage_class              = var.storage_class
  uniform_bucket_level_access = true   # Enable uniform bucket-level access for security
  force_destroy = true

  # Enable versioning if specified
  versioning {
    enabled = var.versioning_enabled
  }

  # Lifecycle rules for object management
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lookup(each.value.action, "type", null)
        storage_class = lookup(each.value.action, "storage_class", null)
      }

      condition {
        age                   = lookup(each.value.condition, "age", null)
        created_before        = lookup(each.value.condition, "created_before", null)
        matches_storage_class = lookup(each.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(each.value.condition, "num_newer_versions", null)
      }
    }
  }

  labels = var.labels
}
