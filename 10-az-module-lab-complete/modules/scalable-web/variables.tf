# Resource Group Location, defaulting to Central US
variable "resource_group_location" {
  type        = string
  default     = "centralus"
  description = "Location of the resource group."
}

# Username to be used in VMSS, defaulting to azureadmin
variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "azureadmin"
}

# VM count, defaulting to 2, minimum 2, maximum 4 
variable "vm_count" {
  type        = number
  description = "The number of VMs to create in the scale set."
  default     = 2
  validation {
    condition     = var.vm_count >= 2 && var.vm_count <= 4
    error_message = "The number of VMs must be between 2 and 4."
  }
}

# App name, defaulting to "Terraform ScaleSet"
variable "app_name" {
  type        = string
  description = "The name of the application to install on the VMs."
  default     = "Terraform ScaleSet"
}

# App prefix, 4 lowercase letters only, defaulting to "demo"
variable "app_prefix" {
  type        = string
  description = "Application prefix, 4 lowercase letters."
  validation {
    condition     = length(var.app_prefix) == 4 && can(regex("^[a-z]{4}$", var.app_prefix))
    error_message = "app_prefix must be exactly 4 lowercase letters (a-z)."
  }
  default = "demo"
}