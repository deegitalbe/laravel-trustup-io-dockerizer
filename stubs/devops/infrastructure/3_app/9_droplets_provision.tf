locals {
  app_folder = "/opt/apps/${var.TRUSTUP_APP_KEY_SUFFIXED}"
  storage_folder = "/mnt/${digitalocean_spaces_bucket.distributed.name}"
  data_folder = "/mnt/${digitalocean_volume.data.name}"
}

locals {
  provide_cluster_command = <<-EOT
    # INSTALL DOCKER
    curl https://get.docker.com | sudo sh && \
    # INSTALL DOPPLER
    (curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh || wget -t 3 -qO- https://cli.doppler.com/install.sh) | sudo sh && \
    # INSTALL S3FS
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y s3fs && \
    # CREATE PROJECT FOLDER
    mkdir -p ${local.app_folder}/stacks && \
    # CREATE REDIS DATA FOLDER
    mkdir -p ${local.data_folder}/redis/data && \
    # CREATE SWARMPIT DATA FOLDERS
    mkdir -p ${local.data_folder}/couchdb/data && \
    mkdir -p ${local.data_folder}/influxdb/data && \
    # MOUNT STORAGE TO DISK
    mkdir -p ${local.storage_folder} && \
    s3fs ${digitalocean_spaces_bucket.distributed.name} ${local.storage_folder} \
        -o url=https://${local.region}.digitaloceanspaces.com \
        -o allow_other \
        -o umask=000
  EOT
}

data "doppler_secrets" "ci_commons" {
  project = "trustup-io-ci-commons"
  config = "github"
}

locals {
  s3fs_config_content = "${data.doppler_secrets.ci_commons.map.DIGITALOCEAN_SPACES_ACCESS_KEY_ID}:${data.doppler_secrets.ci_commons.map.DIGITALOCEAN_SPACES_SECRET_ACCESS_KEY}"
  s3fs_config_location = "/etc/passwd-s3fs"
  s3fs_config_permissions = "0600"
}

resource "ssh_resource" "provide_manager" {
  depends_on = [ 
    digitalocean_firewall.firewall,
    digitalocean_volume_attachment.data_to_manager
  ]
  when = "create"
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "5m"
  file {
    content = local.s3fs_config_content
    destination = local.s3fs_config_location
    permissions = local.s3fs_config_permissions
  }
  commands = [ local.provide_cluster_command ]
}

resource "ssh_resource" "provide_workers" {
  count = local.workers
  depends_on = [ digitalocean_firewall.firewall ]
  when = "create"
  host         = digitalocean_droplet.workers[count.index].ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "5m"
  file {
    content = local.s3fs_config_content
    destination = local.s3fs_config_location
    permissions = local.s3fs_config_permissions
  }
  commands = [ local.provide_cluster_command ]
}
