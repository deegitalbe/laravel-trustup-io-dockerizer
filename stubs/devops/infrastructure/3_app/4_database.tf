data "digitalocean_sizes" "database_size" {
  filter {
    key    = "vcpus"
    values = [ local.database_cpu ]
  }
  filter {
    key    = "memory"
    values = [ local.database_ram ]
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

resource "digitalocean_database_cluster" "database" {
  name       = var.TRUSTUP_APP_KEY_SUFFIXED
  engine     = local.database_engine
  version    = local.database_version
  size       = "db-${data.digitalocean_sizes.database_size.sizes[0].slug}"
  region     = local.region
  node_count = 1
}

resource "doppler_secret" "database_name" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "DB_DATABASE"
  value = digitalocean_database_cluster.database.database
}

resource "doppler_secret" "database_host" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "DB_HOST"
  value = digitalocean_database_cluster.database.host
}

resource "doppler_secret" "database_port" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "DB_PORT"
  value = digitalocean_database_cluster.database.port
}

resource "doppler_secret" "database_user" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "DB_USERNAME"
  value = digitalocean_database_cluster.database.user
}

resource "doppler_secret" "database_user_password" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "DB_PASSWORD"
  value = digitalocean_database_cluster.database.password
}
