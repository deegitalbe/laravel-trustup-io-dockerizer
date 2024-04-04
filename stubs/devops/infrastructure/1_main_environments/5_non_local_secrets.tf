locals {
  non_local_secrets = {
    CACHE_DRIVER = "redis"
    DB_CONNECTION = "mysql"
    FILESYSTEM_DISK = "s3"
    LOG_CHANNEL = "flare"
    LOG_DEPRECATIONS_CHANNEL = "null"
    LOG_LEVEL = "debug"
    QUEUE_CONNECTION = "redis"
    REDIS_HOST = "redis"
    REDIS_PORT = "6379"
    SCOUT_DRIVER = "meilisearch"
    SESSION_DRIVER = "redis"
    SESSION_LIFETIME = "120"
  }
}

locals {
  non_local_environments = { 
    for environment in local.environments : 
      environment => environment 
        if environment != local.environments.local && environment != local.environments.ci
  }
}

data "doppler_secrets" "non_local_secrets" {
  for_each = local.non_local_environments
  depends_on = [ doppler_environment.environments ]
  project = doppler_project.project.name
  config = each.value
}

locals {
  flat_non_local_secrets = flatten([
    for environment in local.non_local_environments : [
      for secret_name, secret_value in local.non_local_secrets : {
        environment = environment
        secret = {
          name: secret_name
          value: secret_value
        }
      }
    ]
  ])
}

resource "doppler_secret" "non_local_secrets" {
  depends_on = [
    doppler_environment.environments,
    doppler_secret.local_secrets,
    doppler_secret.ci_commons_secrets
  ]
  for_each = { 
    for environment_secret in local.flat_non_local_secrets: 
      "${environment_secret.environment}.${environment_secret.secret.name}" => environment_secret
  }
  project = doppler_project.project.name
  config = each.value.environment
  name = each.value.secret.name
  value = lookup(data.doppler_secrets.non_local_secrets[each.value.environment], each.value.secret.name, each.value.secret.value)
}
