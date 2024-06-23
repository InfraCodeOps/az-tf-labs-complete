variable "user_email_domain" {
  # Please specify domain that works with your Azure AD tenant
  # use an auto tfvars file and avoid hardcoding data in config files
  description = "The domain to use for the user email addresses"
}

locals {
  user_data = csvdecode(file("${path.module}/users.csv"))
  user_email_domain = var.user_email_domain
}

# Random prefix since all students share the same Azure AD tenant
# This way we can avoid conflicts with existing users
resource "random_string" "prefix" {
  length  = 4
  special = false
  upper   = false
}

resource "random_password" "password" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}

resource "azuread_user" "ad_users" {
  for_each = { for user in local.user_data : user.alias => user }

  user_principal_name = "${random_string.prefix.result}-${each.value.alias}@${local.user_email_domain}"
  display_name        = "${random_string.prefix.result}-${each.value.firstname}-${each.value.lastname}"
  password            = random_password.password.result
}

#output that lists all user principal names using splat operator
output "user_principal_names" {
  value = [for user in azuread_user.ad_users : user.user_principal_name]

  #splat equivalent is:
  #value = values(azuread_user.ad_users)[*].user_principal_name
}

output "random_prefix" {
  value = random_string.prefix.result
}

# to query any users with that prefix in their email using az cli use :
# az ad user list --query "[?starts_with(userPrincipalName, '$(terraform output -raw random_prefix)')]" --output table
