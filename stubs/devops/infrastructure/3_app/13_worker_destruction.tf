resource "ssh_resource" "disconnect_workers_from_swarm" {
  count = local.workers
  when = "destroy"
  host         = digitalocean_droplet.workers[count.index].ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "5m"
  commands = [ "docker swarm leave" ]
}
