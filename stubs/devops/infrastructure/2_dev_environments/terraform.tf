terraform {
  required_providers {
    doppler = {
      source = "DopplerHQ/doppler"
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