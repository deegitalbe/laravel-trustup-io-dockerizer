resource "ssh_resource" "copy_container_storage_to_distributed_storage" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    digitalocean_database_firewall.firewall,
    ssh_resource.initialize_swarm,
    ssh_resource.create_swarm_public_network,
    ssh_resource.connect_workers_to_swarm,
    ssh_resource.set_manager_env_file,
    ssh_resource.set_workers_env_file,
  ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands = [
    <<-EOT
      docker run \
        --rm \
        --mount type=bind,source=${local.app_folder}/.env,target=/opt/apps/app/.env \
        --mount type=bind,source=${local.storage_folder},target=/mnt/storage \
        henrotaym/${var.TRUSTUP_APP_KEY}-cli:${var.DOCKER_IMAGE_TAG} \
        cp -a /opt/apps/app/storage /mnt/storage
    EOT
  ]
}

locals {
  docker_compose_file = "stacks/app-docker-compose.yml"
  swarmpit_compose_file = "stacks/swarmpit-docker-compose.yml"
}

resource "ssh_resource" "deploy_app_stack" {
  when = "create"
  depends_on = [
    ssh_resource.set_manager_env_file,
    ssh_resource.set_workers_env_file,
    ssh_resource.copy_container_storage_to_distributed_storage
  ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  file {
    content = file(local.docker_compose_file)
    destination = "${local.app_folder}/${local.docker_compose_file}"
  }
  commands_after_file_changes = true
  commands = [
    <<-EOT
      export DOCKER_IMAGE_TAG=${var.DOCKER_IMAGE_TAG} && \
      export CLOUDFLARE_API_TOKEN=${data.doppler_secrets.ci_commons.map.CLOUDFLARE_API_TOKEN} && \
      export CLOUDFLARE_API_EMAIL=${data.doppler_secrets.ci_commons.map.CLOUDFLARE_API_EMAIL} && \
      export APP_FOLDER=${local.app_folder} && \
      export DATA_FOLDER=${local.data_folder} && \
      export STORAGE_FOLDER=${local.storage_folder} && \
      export APP_URL=${cloudflare_record.app_dns_record.hostname} && \
      export APP_KEY=${var.TRUSTUP_APP_KEY} && \
      docker stack deploy -c ${local.app_folder}/${local.docker_compose_file} app && \
      unset DOCKER_IMAGE_TAG && \
      unset CLOUDFLARE_API_TOKEN && \
      unset CLOUDFLARE_API_EMAIL && \
      unset APP_FOLDER && \
      unset DATA_FOLDER && \
      unset STORAGE_FOLDER && \
      unset APP_URL && \
      unset APP_KEY
    EOT
  ]
}

resource "ssh_resource" "deploy_swarmpit_stack" {
  depends_on = [
    ssh_resource.initialize_swarm,
    ssh_resource.create_swarm_public_network,
    ssh_resource.connect_workers_to_swarm
  ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  file {
    content = file(local.swarmpit_compose_file)
    destination = "${local.app_folder}/${local.swarmpit_compose_file}"
  }
  commands_after_file_changes = true
  commands = [
    <<-EOT
      export DATA_FOLDER=${local.data_folder} && \
      export SWARMPIT_URL=${cloudflare_record.swarmpit_dns_record.hostname} && \
      docker stack deploy -c ${local.app_folder}/${local.swarmpit_compose_file} swarmpit && \
      unset DATA_FOLDER && \
      unset SWARMPIT_URL
    EOT
  ]
}

resource "ssh_resource" "deploy_app_fpm" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    ssh_resource.copy_container_storage_to_distributed_storage,
    ssh_resource.deploy_app_stack
  ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands_after_file_changes = true
  commands = [
    <<-EOT
      docker service update \
        --force \
        --image henrotaym/${var.TRUSTUP_APP_KEY}-fpm:${var.DOCKER_IMAGE_TAG} \
        --replicas ${local.fpm_replicas} \
        app_fpm
    EOT
  ]
}

resource "ssh_resource" "deploy_app_queue" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    ssh_resource.copy_container_storage_to_distributed_storage,
    ssh_resource.deploy_app_stack
  ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands_after_file_changes = true
  commands = [
    <<-EOT
      docker service update \
        --force \
        --image henrotaym/${var.TRUSTUP_APP_KEY}-cli:${var.DOCKER_IMAGE_TAG} \
        --replicas ${local.queue_replicas} \
        app_queue
    EOT
  ]
}

resource "ssh_resource" "deploy_app_cron" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    ssh_resource.copy_container_storage_to_distributed_storage,
    ssh_resource.deploy_app_stack
  ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands_after_file_changes = true
  commands = [
    <<-EOT
      docker service update \
        --force \
        --image henrotaym/${var.TRUSTUP_APP_KEY}-cron:${var.DOCKER_IMAGE_TAG} \
        --replicas ${local.cron_replicas} \
        app_cron
    EOT
  ]
}

resource "ssh_resource" "deploy_app_web" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    ssh_resource.deploy_app_fpm
  ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands_after_file_changes = true
  commands = [
    <<-EOT
      docker service update \
        --force \
        --image henrotaym/${var.TRUSTUP_APP_KEY}-web:${var.DOCKER_IMAGE_TAG} \
        --replicas ${local.web_replicas} \
        app_web
    EOT
  ]
}

resource "ssh_resource" "migrate_database" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    ssh_resource.deploy_app_cron,
    ssh_resource.deploy_app_fpm,
    ssh_resource.deploy_app_queue,
    ssh_resource.deploy_app_web
  ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands = [
    "docker container prune --force",
    "docker image prune --force",
    <<-EOT
      docker run \
        --rm \
        --mount type=bind,source=${local.app_folder}/.env,target=/opt/apps/app/.env \
        --mount type=bind,source=${local.storage_folder}/storage,target=/opt/apps/app/storage \
        henrotaym/${var.TRUSTUP_APP_KEY}-cli:${var.DOCKER_IMAGE_TAG} \
        php artisan migrate --force
    EOT
  ]
}