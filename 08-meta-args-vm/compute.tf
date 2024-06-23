# Decode CSV file into a list of user records
locals {
  userinfo = csvdecode(file("${path.module}/users.csv"))
}

resource "azurerm_virtual_network" "infra_vnet" {
  name                = "infra-vnet"
  location            = azurerm_resource_group.infra_rg.location
  resource_group_name = azurerm_resource_group.infra_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "infra_subnet" {
  name                 = "infra-subnet"
  resource_group_name  = azurerm_resource_group.infra_rg.name
  virtual_network_name = azurerm_virtual_network.infra_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a network interface for each user
resource "azurerm_network_interface" "infra_nic" {
  for_each = { for user in local.userinfo : user.email => user }

  name                = "${each.value.name}-nic"
  location            = azurerm_resource_group.infra_rg.location
  resource_group_name = azurerm_resource_group.infra_rg.name

  ip_configuration {
    name                          = "${each.value.name}-ipconfig"
    subnet_id                     = azurerm_subnet.infra_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a Linux VM for each user
# Heads up: in a future lab we will use scale sets instead of individual VMs
resource "azurerm_linux_virtual_machine" "infra_vms" {
  for_each = azurerm_network_interface.infra_nic

  # Heads up: this will only work if the first names are unique
  name                = "infra-vm-${each.value.name}"
  location            = azurerm_resource_group.infra_rg.location
  resource_group_name = azurerm_resource_group.infra_rg.name
  size                = "Standard_B1ls"

  network_interface_ids = [each.value.id]

  admin_username = "adminuser"

  # Heads up: this is not a real password
  # Nor is this a good practice except to showcase
  # certain Terraform concepts.
  # Ideally you would use SSH keys instead of passwords
  admin_password = "notapassword1234!"

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching                     = "ReadWrite"
    storage_account_type        = "Standard_LRS"
    // delete disk on termination
    # delete_on_termination       = true
  }

  tags = {
    Name = each.value.name
  }
}

# Outputs list of VM identifiers
output "vm_ids" {
  value = [for vm in azurerm_linux_virtual_machine.infra_vms : vm.id]
}

# Returns a map where keys are the instance names and values are their respective IDs
output "vm_names_ids" {
  value = { for email, vm in azurerm_linux_virtual_machine.infra_vms : email => vm.id }
}