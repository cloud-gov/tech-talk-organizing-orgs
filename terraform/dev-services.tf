data "cloudfoundry_service" "aws-rds" {
  name = "aws-rds"
}

# MANAGED SERVICES

resource "cloudfoundry_service_instance" "api-db" {
  name         = "api-db"
  space        = cloudfoundry_space.dev-space.id
  service_plan = data.cloudfoundry_service.aws-rds.service_plans["micro-psql"]
}

# Service key
resource "cloudfoundry_service_key" "api-db-monitoring-key" {
  name = "api-db-monitoring-key"
  service_instance = cloudfoundry_service_instance.api-db.id
}


# USER PROVIDED SERVICE INSTANCES

# Put some comments here. What is this? Why does it exist? What uses it?
resource "cloudfoundry_user_provided_service" "basic-auth" {
  name  = "basic-auth"
  space = cloudfoundry_space.dev-space.id
  credentials = {
    "username" = "admin"
    "password" = "this-should-be-an-injected-variable"
  }
}