# Random string of size four, all lower case letters
resource "random_string" "randomizer" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

# A local variable called app-code that combines the app_prefix and the 
# random string with a dash in between: <app_prefix>-<random>
# This will be used in all major resource names as a suffix to ensure uniqueness
locals {
  app_code = "${var.app_prefix}-${random_string.randomizer.result}"
}

############################################

# Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "rg-${local.app_code}"
}


# This resource creates a dynamic script file
# With  the application name injected into 
# the bash script. For this, we use a template file
# and use the templatefile function to inject the
# application name into the script file
resource "local_file" "script_file" {
  filename = "${path.module}/script/installweb.sh"
  content  = templatefile("${path.module}/script/installweb.tftpl", {
    app_name = var.app_name
    app_code = local.app_code
  })
}


# Virtual Machine Scale Set Extension to install the application
resource "azurerm_virtual_machine_scale_set_extension" "vmss_script_extension" {
  name                         = "${azurerm_linux_virtual_machine_scale_set.infra_scale_set.name}-script-extension"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.infra_scale_set.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings = jsonencode({
    "script" = base64encode(local_file.script_file.content)
  })
  auto_upgrade_minor_version = true
}