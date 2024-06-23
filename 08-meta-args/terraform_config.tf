terraform {
  required_version = "~>1.8"
  required_providers {

    # No need for azurerm provider as we are only creating ad users
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = "~>3.0"
    # }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.4"
    }
  }
}

provider "azurerm" {
  features {}
}