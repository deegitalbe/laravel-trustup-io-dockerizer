locals {
  developers_ssh_keys = split(",", data.doppler_secrets.ci_commons.map.DIGITALOCEAN_DEVELOPERS_SSH_KEYS)
}

data "digitalocean_ssh_keys" "ssh_keys" {
  filter {
    key    = "name"
    values = local.developers_ssh_keys
  }
}

resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 3072
}

resource "local_file" "ssh_key" {
  content = tls_private_key.ssh_private_key.private_key_pem
  filename = "./private_key"
  file_permission = 600
}

resource "digitalocean_ssh_key" "ssh_key" {
  name = "${var.TRUSTUP_APP_KEY_SUFFIXED}-ssh-key"
  public_key = chomp(tls_private_key.ssh_private_key.public_key_openssh)
}
