# Cloud Storage (dùng lưu tài liệu, model)
resource "google_storage_bucket" "this" {
  name          = var.bucket_name
  project       = var.project_id
  location      = var.location
  storage_class = var.storage_class

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

resource "google_storage_bucket_iam_binding" "bindings" {
  for_each = { for idx, b in var.iam_bindings : idx => b }

  bucket  = google_storage_bucket.this.name
  role    = each.value.role
  members = lookup(each.value, "members", [])
}