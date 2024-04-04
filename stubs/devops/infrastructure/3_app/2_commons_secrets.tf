locals {
  is_production = var.APP_ENVIRONMENT == "production"
  doppler_secret_same_as_suffixed_app_key = [
    "TRUSTUP_APP_KEY",
    "TRUSTUP_IO_APP_KEY",
    "TRUSTUP_MODEL_BROADCAST_APP_KEY"
  ]
}

locals {
  doppler_app_config = local.is_production ? "production" : var.TRUSTUP_APP_KEY_SUFFIX
}

data "doppler_secrets" "app" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
}

resource "doppler_secret" "app_name" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "APP_NAME"
  value = lookup(data.doppler_secrets.app.map, "APP_NAME", var.TRUSTUP_APP_KEY_SUFFIXED)
}

resource "doppler_secret" "mail_from_name" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "MAIL_FROM_NAME"
  value = lookup(data.doppler_secrets.app.map, "MAIL_FROM_NAME", doppler_secret.app_name.value)
}

resource "doppler_secret" "same_as_suffixed_app_key" {
  for_each = toset(local.doppler_secret_same_as_suffixed_app_key)
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = each.value
  value = lookup(data.doppler_secrets.app.map, each.value, var.TRUSTUP_APP_KEY_SUFFIXED)
}

resource "doppler_secret" "messaging_app_key" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "TRUSTUP_MESSAGING_APP_KEY"
  value = lookup(data.doppler_secrets.app.map, "TRUSTUP_MESSAGING_APP_KEY", var.TRUSTUP_APP_KEY_SUFFIXED)
}

resource "doppler_secret" "flare_key" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "FLARE_KEY"
  value = lookup(data.doppler_secrets.app.map, "FLARE_KEY", "")
}

resource "doppler_secret" "deployed_image_tag" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "DEPLOYED_IMAGE_TAG"
  value = lookup(data.doppler_secrets.app.map, "DEPLOYED_IMAGE_TAG", var.DOCKER_IMAGE_TAG)
}

resource "doppler_secret" "app_env" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "APP_ENV"
  value = local.is_production ? "production" : "staging"
}

resource "doppler_secret" "app_debug" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "APP_DEBUG"
  value = !local.is_production
}

resource "doppler_secret" "app_key" {
  project = var.TRUSTUP_APP_KEY
  config = local.doppler_app_config
  name = "APP_KEY"
  value = lookup(data.doppler_secrets.app.map, "APP_KEY", "base64:${base64sha256(var.TRUSTUP_APP_KEY_SUFFIXED)}")
}
