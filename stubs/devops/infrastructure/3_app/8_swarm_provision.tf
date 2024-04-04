resource "ssh_resource" "initialize_swarm" {
  when = "create"
  depends_on = [ ssh_resource.provide_manager ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands = [
    "docker swarm init --advertise-addr ${digitalocean_droplet.manager.ipv4_address}",
  ]
}

resource "ssh_resource" "connect_workers_to_swarm" {
  count = local.workers
  depends_on = [
    ssh_resource.provide_workers,
    ssh_resource.initialize_swarm
  ]
  when = "create"
  host         = digitalocean_droplet.workers[count.index].ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands = [
    regex("docker swarm join --token \\S+ ${digitalocean_droplet.manager.ipv4_address}:\\d+", ssh_resource.initialize_swarm.result)
  ]
}

resource "ssh_resource" "create_swarm_public_network" {
  when = "create"
  depends_on = [ ssh_resource.initialize_swarm ]
  host         = digitalocean_droplet.manager.ipv4_address
  user         = "root"
  private_key = tls_private_key.ssh_private_key.private_key_pem
  timeout     = "1m"
  commands = [
    "docker network create -d overlay public"
  ]
}
