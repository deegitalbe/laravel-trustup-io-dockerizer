provider "doppler" {
  doppler_token = var.DOPPLER_ACCESS_TOKEN_USER
}

provider "digitalocean" {
  token = data.doppler_secrets.ci_commons.map.DIGITALOCEAN_ACCESS_TOKEN
  spaces_access_id  = data.doppler_secrets.ci_commons.map.DIGITALOCEAN_SPACES_ACCESS_KEY_ID
  spaces_secret_key = data.doppler_secrets.ci_commons.map.DIGITALOCEAN_SPACES_SECRET_ACCESS_KEY
}

provider "cloudflare" {
  api_key = data.doppler_secrets.ci_commons.map.CLOUDFLARE_API_TOKEN
  email = data.doppler_secrets.ci_commons.map.CLOUDFLARE_API_EMAIL
}