terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.14.1"
    }
  }
}

provider "cloudfoundry" {
  api_url  = var.cf_api
  user     = var.cf_username
  password = var.cf_password
}

data "cloudfoundry_org" "org" {
  name = var.cf_org
}