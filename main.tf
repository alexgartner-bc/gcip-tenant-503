provider "google" {
  project     = "bc-roc-poc"
  region      = "us-west2"
}

locals {
  tenant_names   = [for idx in range(200) : format("test%d", idx)]
}

resource "google_project_service" "project_service" {
  service = "iap.googleapis.com"
}

resource "google_identity_platform_tenant" "tenant" {
  for_each = toset(local.tenant_names)
  display_name = each.value
  allow_password_signup = true
}

# reserved IP address
resource "google_compute_global_address" "default" {
  name     = "gcip-tenant-503"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "gcip-tenant-503"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  name     = "gcip-tenant-503"
  url_map  = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  name            = "gcip-tenant-503"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name          = "gcip-tenant-503"
  health_checks = [google_compute_http_health_check.default.id]
}

resource "google_compute_http_health_check" "default" {
  name               = "gcip-tenant-503"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

output "tenant_ids" {
    value = flatten([
        for key, value in google_identity_platform_tenant.tenant: [
            split("/", value.id)[3]
        ]
    ]
    )
}