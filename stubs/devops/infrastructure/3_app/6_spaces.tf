resource "digitalocean_spaces_bucket" "distributed" {
  name   = "${var.TRUSTUP_APP_KEY_SUFFIXED}-distributed"
  region = local.region
}

resource "digitalocean_spaces_bucket" "storage" {
  name   = "${var.TRUSTUP_APP_KEY_SUFFIXED}"
  region = local.region
}

resource "digitalocean_spaces_bucket_cors_configuration" "storage_space" {
  bucket = digitalocean_spaces_bucket.storage.id
  region = local.region
  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

locals {
  cloudflare_dns_zone_id = lookup(data.doppler_secrets.ci_commons.map, var.CLOUDFLARE_ZONE_SECRET, data.doppler_secrets.ci_commons.map.CLOUDFLARE_DNS_ZONE_TRUSTUP_IO)
}

resource "cloudflare_record" "storage_space_cdn" {
  zone_id = local.cloudflare_dns_zone_id
  name    = var.BUCKET_URL
  value =  "${digitalocean_spaces_bucket.storage.name}.${digitalocean_spaces_bucket.storage.region}.cdn.digitaloceanspaces.com"
  proxied = true
  type    = "CNAME"
}

resource "doppler_secret" "storage_space_name" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "DO_BUCKET"
  value = digitalocean_spaces_bucket.storage.name
}

resource "doppler_secret" "storage_space_region" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "DO_DEFAULT_REGION"
  value = digitalocean_spaces_bucket.storage.region
}

resource "doppler_secret" "storage_space_endpoint" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "DO_ENDPOINT"
  value = "https://${digitalocean_spaces_bucket.storage.endpoint}"
}

resource "doppler_secret" "storage_space_cdn_url" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "DO_URL"
  value = "https://${var.BUCKET_URL}"
}
