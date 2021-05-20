# Space quota
resource "cloudfoundry_space_quota" "dev-quota" {
  name                     = "dev-quota"
  allow_paid_service_plans = true
  instance_memory          = 512
  total_memory             = 5120
  total_app_instances      = 10
  total_routes             = 5
  total_services           = 20
  org                      = data.cloudfoundry_org.org.id
}

# The space
resource "cloudfoundry_space" "dev-space" {
  name      = "dev"
  org       = data.cloudfoundry_org.org.id
  quota     = cloudfoundry_space_quota.dev-quota.id
  allow_ssh = true
}

# Users and roles
resource "cloudfoundry_space_users" "space-users" {
  space      = cloudfoundry_space.dev-space.id
  force      = true
  managers   = var.dev-managers
  developers = var.dev-developers
  auditors   = var.dev-auditors
}