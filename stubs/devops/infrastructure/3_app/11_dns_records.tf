resource "cloudflare_record" "app_dns_record" {
  zone_id = local.cloudflare_dns_zone_id
  name    = var.APP_URL
  value   = digitalocean_droplet.manager.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "swarmpit_dns_record" {
  zone_id = local.cloudflare_dns_zone_id
  name    = "swarmpit-${var.APP_URL}"
  value   = digitalocean_droplet.manager.ipv4_address
  type    = "A"
  proxied = true
}

resource "doppler_secret" "app_url" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "APP_URL"
  value = "https://${cloudflare_record.app_dns_record.hostname}"
}
