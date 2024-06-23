terraform {
  # Your version might be different
  # The code below instructs Terraform 
  # to use v1.6.0 and above up to
  # but not including v2.0.0
  required_version = "~> 1.6"

  # Inform Terraform to use the Azure provider
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # pinning to v3.x
      version = "~> 3.0"
    }
  }
}

# Configure the Azure provider
# This block is required by the Azure provider
# even if we don't provide any features
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "infra_rg" {
  name     = "infra-rg-05"
  location = "centralus"
}