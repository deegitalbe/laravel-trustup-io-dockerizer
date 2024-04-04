locals {
  environments = {
    local = "local"
    staging = "staging"
    production = "production"
    ci = "ci"
  }
}

resource "doppler_environment" "environments" {
  for_each = local.environments
  project = doppler_project.project.name
  name = each.value
  slug = each.value
}
