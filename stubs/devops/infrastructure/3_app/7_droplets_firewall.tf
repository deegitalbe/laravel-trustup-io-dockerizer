locals {
  firewall_all_adresses = [ "0.0.0.0/0", "::/0" ]
  ingoing_ports = [
    { protocol: "tcp", port: "22", public: true },
  ]
  outgoing_ports = [
    { protocol: "tcp", port: "53", public: true },
    { protocol: "udp", port: "53", public: true },
  ]
  both_mode_ports = [
    { protocol: "tcp", port: "80", public: true },
    { protocol: "tcp", port: "443", public: true },
    { protocol: "tcp", port: "2377", public: false },
    { protocol: "tcp", port: "7946", public: false },
    { protocol: "udp", port: "7946", public: false },
    { protocol: "udp", port: "4789", public: false },
    { protocol: "tcp", port: "25060", public: true },
  ]
}

locals {
  droplet_ids = [for value in concat([digitalocean_droplet.manager], digitalocean_droplet.workers): value.id]
}

resource "digitalocean_firewall" "firewall" {
  depends_on = [
    digitalocean_droplet.manager,
    digitalocean_droplet.workers
  ]
  name = "${var.TRUSTUP_APP_KEY_SUFFIXED}-firewall"
  droplet_ids = local.droplet_ids
  dynamic "inbound_rule" {
    for_each = local.ingoing_ports
    content {
      protocol = inbound_rule.value.protocol
      port_range = inbound_rule.value.port
      source_addresses = inbound_rule.value.public ? local.firewall_all_adresses : []
      source_droplet_ids = inbound_rule.value.public ? [] : local.droplet_ids
    }
  }
  dynamic "outbound_rule" {
    for_each = local.outgoing_ports
    content {
      protocol = outbound_rule.value.protocol
      port_range = outbound_rule.value.port
      destination_addresses = outbound_rule.value.public ? local.firewall_all_adresses : []
      destination_droplet_ids = outbound_rule.value.public ? [] : local.droplet_ids
    }
  }
  dynamic "inbound_rule" {
    for_each = local.both_mode_ports
    content {
      protocol = inbound_rule.value.protocol
      port_range = inbound_rule.value.port
      source_addresses = inbound_rule.value.public ? local.firewall_all_adresses : []
      source_droplet_ids = inbound_rule.value.public ? [] : local.droplet_ids
    }
  }
  dynamic "outbound_rule" {
    for_each = local.both_mode_ports
    content {
      protocol = outbound_rule.value.protocol
      port_range = outbound_rule.value.port
      destination_addresses = outbound_rule.value.public ? local.firewall_all_adresses : []
      destination_droplet_ids = outbound_rule.value.public ? [] : local.droplet_ids
    }
  }
}
