locals {
  region = "ams3"
  distro_name = "ubuntu"
  distro_version = "22"
  manager_cpu = 1
  manager_ram = 2048
  worker_cpu = 1
  worker_ram = 2048
  database_cpu = 1
  database_ram = 1024
  database_engine = "mysql"
  database_version = "8"
  data_volume_size_in_gigabytes = 10
  workers = 0
  fpm_replicas = 1
  web_replicas = 1
  cron_replicas = 1
  queue_replicas = 1
}
