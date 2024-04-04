locals {
  droplet_ssh_key_fingerprints = [
    for key in concat([digitalocean_ssh_key.ssh_key], data.digitalocean_ssh_keys.ssh_keys.ssh_keys):
      key.fingerprint
  ]
}

data "digitalocean_images" "distro_image" {
  filter {
    key    = "regions"
    values = [ local.region ]
  }
  filter {
    key = "private"
    values = [ false ]
  }
  filter {
    key = "slug"
    values = [ "${local.distro_name}-${local.distro_version}" ]
    match_by = "substring"
  }
  sort {
    key       = "created"
    direction = "desc"
  }
}

data "digitalocean_sizes" "manager_size" {
  filter {
    key    = "vcpus"
    values = [ local.manager_cpu ]
  }
  filter {
    key    = "memory"
    values = [ local.manager_ram ]
  }
  filter {
    key    = "regions"
    values = [ local.region ]
  }
  sort {
    key       = "price_monthly"
    direction = "asc"
  }
}

data "digitalocean_sizes" "worker_size" {
  filter {
    key    = "vcpus"
    values = [ local.worker_cpu ]
  }
  filter {
    key    = "memory"
    values = [ local.worker_ram ]
  }
  filter {
    key    = "regions"
    values = [ local.region ]
  }
  sort {
    key       = "price_monthly"
    direction = "asc"
  }
}

locals {
  distro_image = data.digitalocean_images.distro_image.images[0].slug
  manager_size = data.digitalocean_sizes.manager_size.sizes[0].slug
  worker_size = data.digitalocean_sizes.worker_size.sizes[0].slug
}

resource "digitalocean_droplet" "manager" {
  image  = local.distro_image
  name   = var.TRUSTUP_APP_KEY_SUFFIXED
  region = local.region
  size   = local.manager_size
  ssh_keys = local.droplet_ssh_key_fingerprints
  monitoring = true
}

resource "digitalocean_droplet" "workers" {
  depends_on = [ digitalocean_droplet.manager ]
  count = local.workers
  image  = local.distro_image
  name   = "${var.TRUSTUP_APP_KEY_SUFFIXED}-worker-${count.index}"
  region = local.region
  size   = local.worker_size
  ssh_keys = local.droplet_ssh_key_fingerprints
  monitoring = true
}
