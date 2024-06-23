
# Heads up!
# In real-world scenarios you would use a secrets management tool
# We will use a random password for the VM admin password
# Regardless, secrets WILL be stored in plain text in the state file
# Always ensure your state file is secure (encrypted and access controlled).
resource "random_password" "vm_password" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}


# An Azure VM with Windows Server 2022 Datacenter
resource "azurerm_windows_virtual_machine" "infra_vm" {
  name                  = "infra-vm"
  resource_group_name   = azurerm_resource_group.infra_rg.name
  location              = azurerm_resource_group.infra_rg.location
  size                  = "Standard_B2s"
  admin_username        = "adminuser"
  admin_password        = random_password.vm_password.result
  network_interface_ids = [azurerm_network_interface.infra_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = {
    "Name" = "Infra Virtual Machine"
  }
}

output "infra_vm_public_ip" {
  value = azurerm_windows_virtual_machine.infra_vm.public_ip_address
}

output "infra_vm_admin_pwd" {
  sensitive = true
  value     = azurerm_windows_virtual_machine.infra_vm.admin_password
}

# Verify that the VM was created using the following AZ CLI command:
# az vm show --resource-group infra-rg-04 --name infra-vm