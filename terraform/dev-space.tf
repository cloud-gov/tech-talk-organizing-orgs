data "cloudfoundry_org" "org" {
    name = var.cf_org
}

# Space quota
resource "cloudfoundry_space_quota" "dev-quota" {
    name = "dev-quota"
    allow_paid_service_plans = true
    instance_memory = 512
    total_memory = 5120
    total_app_instances = 10
    total_routes = 5
    total_services = 20
    org = data.cloudfoundry_org.org.id
}

# The space
resource "cloudfoundry_space" "dev-space" {
    name = "dev"
    org = data.cloudfoundry_org.org.id
    quota = cloudfoundry_space_quota.dev-quota.id
    allow_ssh = true
}

# Users and roles
resource "cloudfoundry_space_users" "space-users" {
  space      = cloudfoundry_space.dev-space.id
  force = true
  managers   = var.dev-managers
  developers = var.dev-developers
  auditors   = var.dev-auditors
}

###################
# MANAGED SERVICES

data "cloudfoundry_service" "aws-rds" {
    name = "aws-rds"
    space        = cloudfoundry_space.dev-space.id
}

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

##################################
# USER PROVIDED SERVICE INSTANCES

# Put some comments here. What is this? Why does it exist? What uses it?
resource "cloudfoundry_user_provided_service" "mq" {
  name = "mq-server"
  space = cloudfoundry_space.dev-space.id
  credentials = {
    "url" = "mq://localhost:9000"
    "username" = "admin"
    "password" = "this-should-be-an-injected-variable"
  }
}