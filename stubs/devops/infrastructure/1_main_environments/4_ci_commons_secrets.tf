locals {
  ci_commons_secrets = [
    "LOCAL_APP_PORT",
    "LOCAL_FORWARD_DB_PORT",
    "LOCAL_FORWARD_REDIS_PORT",
    "LOCAL_VITE_PORT"
  ]
}

data "doppler_secrets" "do_not_use" {
  depends_on = [ 
    doppler_environment.environments,
    doppler_secret.local_secrets
  ]
  project = doppler_project.project.name
  config = local.environments.local
}

resource "doppler_secret" "ci_commons_secrets" {
  depends_on = [ doppler_secret.local_secrets ]
  for_each = toset(local.ci_commons_secrets)
  project = data.doppler_secrets.ci_commons.project
  config = data.doppler_secrets.ci_commons.config
  name = each.value
  value = data.doppler_secrets.ci_commons.map[each.value] == data.doppler_secrets.do_not_use.map[replace(each.value, "LOCAL_", "")] ? sum([data.doppler_secrets.ci_commons.map[each.value], 1]) : data.doppler_secrets.ci_commons.map[each.value]
}
