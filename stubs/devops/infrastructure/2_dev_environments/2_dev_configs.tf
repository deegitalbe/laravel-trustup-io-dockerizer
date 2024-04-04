resource "doppler_config" "dev_configs" {
  for_each = toset(local.current_environments)
  name = "staging_${replace(each.value, "-", "_")}"
  project = var.TRUSTUP_APP_KEY
  environment = "staging"
}