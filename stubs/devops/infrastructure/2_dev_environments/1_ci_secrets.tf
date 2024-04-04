data "doppler_secrets" "ci" {
  project = var.TRUSTUP_APP_KEY
  config = "ci"
}

locals {
  previous_environments_stringified = nonsensitive(lookup(data.doppler_secrets.ci.map, "DEV_RELATED_ENVIRONMENTS", ""))
}

locals {
  previous_environments = split(",", local.previous_environments_stringified)
}

locals {
  current_environments = [
    for environment in distinct(concat(local.previous_environments, [var.DEV_ENVIRONMENT_TO_ADD])) :
      environment if environment != var.DEV_ENVIRONMENT_TO_REMOVE && environment != ""
  ]
}

locals {
  current_environments_stringified = join(",", local.current_environments)
}

resource "doppler_secret" "dev_related_environments" {
  project = data.doppler_secrets.ci.project
  config = data.doppler_secrets.ci.config
  name = "DEV_RELATED_ENVIRONMENTS"
  value = local.current_environments_stringified
}
