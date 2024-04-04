terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.11"
    }
    doppler = {
      source = "DopplerHQ/doppler"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
     tls = {
      source = "hashicorp/tls"
      version = "4.0.5"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.1"
    }
    ssh = {
      source = "loafoe/ssh"
      version = "2.7.0"
    }
  }
  backend "s3" {
    endpoints = { s3 = "https://ams3.digitaloceanspaces.com" }
    region = "ams3"
    skip_region_validation = true
    skip_credentials_validation = true
    skip_requesting_account_id = true
    skip_s3_checksum = true
  }
  required_version = ">1.7"
}
