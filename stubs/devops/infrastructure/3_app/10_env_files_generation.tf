resource "doppler_service_token" "app_commons" {
  project = "trustup-io-app-commons"
  config = var.APP_ENVIRONMENT
  name = var.TRUSTUP_APP_KEY_SUFFIXED
  access = "read"
}

resource "doppler_service_token" "app" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = var.TRUSTUP_APP_KEY_SUFFIXED
  access = "read"
}

locals {
  create_env_file_command = <<-EOT
    cd ${local.app_folder} && \
    export DOPPLER_TOKEN=${doppler_service_token.app_commons.key} && \
    doppler secrets download \
      --project "${doppler_service_token.app_commons.project}" \
      --config "${doppler_service_token.app_commons.config}" \
      --no-file \
      --format env | grep -Ev 'DOPPLER|NUXT' \
      >> .env && \
    export DOPPLER_TOKEN=${doppler_service_token.app.key} && \
    doppler secrets download \
      --project "${doppler_service_token.app.project}" \
      --config ${doppler_service_token.app.config} \
      --no-file \
      --format env | grep -Ev 'DOPPLER|NUXT' \
      >> .env && \
    unset DOPPLER_TOKEN
  EOT
}

resource "ssh_resource" "set_manager_env_file" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    ssh_resource.provide_manager,
    doppler_secret.database_host,
    doppler_secret.database_name,
    doppler_secret.database_port,
    doppler_secret.database_user,
    doppler_secret.database_user_password,
    doppler_secret.storage_space_cdn_url,
    doppler_secret.storage_space_endpoint,
    doppler_secret.storage_space_name,
    doppler_secret.storage_space_region
  ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands = [ local.create_env_file_command ]
}

resource "ssh_resource" "set_workers_env_file" {
  count = local.workers
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [ ssh_resource.provide_workers ]
  host         = digitalocean_droplet.workers[count.index].ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands = [ local.create_env_file_command ]
}
