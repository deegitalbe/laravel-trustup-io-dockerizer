resource "digitalocean_volume" "data" {
  region = local.region
  name = "${var.TRUSTUP_APP_KEY_SUFFIXED}-data"
  size = local.data_volume_size_in_gigabytes
}

resource "digitalocean_volume_attachment" "data_to_manager" {
  droplet_id = digitalocean_droplet.manager.id
  volume_id = digitalocean_volume.data.id
}