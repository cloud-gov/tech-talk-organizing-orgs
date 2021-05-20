#!/bin/bash

# Get set up for terraform by creating a space to hold a service account, bound by a space quota,
# then create the service account and assign the OrgManager role.

set -e

if [[ "$#" -lt 1 ]]; then
  echo " " 
  echo "Usage: "
  echo " "
  echo " ./initialize.sh <ORG_NAME>"
  echo " "
  exit 1
fi

org_name=$1

cf t -o $org_name

# Create a space that will just hold our service account used by Terraform
cf create-space primordial-soup
cf t -s primordial-soup

# Create and apply a quota that only allows a single service instance. This space is just
# for holding the service account and we don't want anyone else using it.
cf create-space-quota primordial-soup-quota -r 0 -s 1 -a 0 
cf set-space-quota primordial-soup primordial-soup-quota

# Create the service account. The role here doesn't really matter as we will
# assign OrgManager next
cf create-service cloud-gov-service-account space-auditor terraform-service-account
cf create-service-key terraform-service-account terraform-service-key

# Extract the username for the service account
service_key_guid=$(cf curl "/v3/service_credential_bindings?names=terraform-service-key&service_instance_names=terraform-service-account&type=key" | jq -r '.resources[].guid')
service_key_json=$(cf curl "/v3/service_credential_bindings/${service_key_guid}/details")
service_key_username=$(echo "$service_key_json" | jq -r '.credentials.username')
service_key_password=$(echo "$service_key_json" | jq -r '.credentials.password')

# Set the service account as an org manager
cf set-org-role $service_key_username $org_name OrgManager

# Create our creds.tfvars for terraform based on the service account
echo 'cf_api = "https://api.fr.cloud.gov"' > terraform/creds.tfvars
echo 'cf_username = "'"${service_key_username}"'"' >> terraform/creds.tfvars
echo 'cf_password = "'"${service_key_password}"'"' >> terraform/creds.tfvars
echo 'cf_org = "'"${org_name}"'"' >> terraform/creds.tfvars