locals {
  database_allowed_ips = nonsensitive(split(",", data.doppler_secrets.ci_commons.map.DIGITALOCEAN_DATABASE_ALLOWED_IPS))
}

resource "digitalocean_database_firewall" "firewall" {
  cluster_id = digitalocean_database_cluster.database.id
  dynamic rule {
    for_each = toset(local.droplet_ids)
    content {
      type = "droplet"
      value = rule.value
    }
  }
  dynamic "rule" {
    for_each = toset(local.database_allowed_ips)
    content {
      type  = "ip_addr"
      value = rule.value
    }
  }
}