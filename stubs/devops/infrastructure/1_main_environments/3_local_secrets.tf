data "doppler_secrets" "ci_commons" {
  project = "trustup-io-ci-commons"
  config = "github"
}

data "doppler_secrets" "local" {
  depends_on = [ doppler_environment.environments ]
  project = doppler_project.project.name
  config = local.environments.local
}

locals {
  local_app_key = "${var.TRUSTUP_APP_KEY}-${local.environments.local}"
}

locals {
  local_secrets = {
    TRUSTUP_APP_KEY = local.local_app_key
    TRUSTUP_IO_APP_KEY = local.local_app_key
    TRUSTUP_MESSAGING_APP_KEY = local.local_app_key
    TRUSTUP_MODEL_BROADCAST_APP_KEY = local.local_app_key
    APP_NAME = local.local_app_key
    APP_ENV = local.environments.local
    APP_KEY = "base64:${base64sha256(var.TRUSTUP_APP_KEY)}"
    APP_DEBUG = "true"
    APP_URL = "https://${var.TRUSTUP_APP_KEY}.docker.localhost"
    VITE_APP_URL = "https://${var.TRUSTUP_APP_KEY}.docker.localhost"
    LOG_CHANNEL = "daily"
    LOG_DEPRECATIONS_CHANNEL = "null"
    LOG_LEVEL = "debug"
    APP_SERVICE = var.TRUSTUP_APP_KEY
    APP_PORT = data.doppler_secrets.ci_commons.map.LOCAL_APP_PORT
    FORWARD_DB_PORT = data.doppler_secrets.ci_commons.map.LOCAL_FORWARD_DB_PORT
    FORWARD_REDIS_PORT = data.doppler_secrets.ci_commons.map.LOCAL_FORWARD_REDIS_PORT
    FORWARD_MEILISEARCH_PORT = data.doppler_secrets.ci_commons.map.LOCAL_FORWARD_MEILISEARCH_PORT
    VITE_PORT = data.doppler_secrets.ci_commons.map.LOCAL_VITE_PORT
    DB_CONNECTION = "mysql"
    DB_HOST = "${var.TRUSTUP_APP_KEY}-mysql"
    DB_PORT = "3306"
    DB_DATABASE = "${var.TRUSTUP_APP_KEY}-db"
    BROADCAST_DRIVER = "log"
    CACHE_DRIVER = "redis"
    FILESYSTEM_DISK = "local"
    QUEUE_CONNECTION = "redis"
    SESSION_DRIVER = "file"
    SESSION_LIFETIME = "120"
    REDIS_HOST = "${var.TRUSTUP_APP_KEY}-redis"
    REDIS_PASSWORD = "null"
    REDIS_PORT = "6379"
  }
}

resource "doppler_secret" "local_secrets" {
  for_each = local.local_secrets
  project = doppler_project.project.name
  config = local.environments.local
  name = each.key
  value = lookup(data.doppler_secrets.local.map, each.key, each.value)
}
