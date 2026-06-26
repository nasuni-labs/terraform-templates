resource "azurerm_public_ip" "playaipnmc" {
  name                = "example-terra-ipnmc"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Dynamic"
}

# We create a fresh network interface for each appliance.
resource "azurerm_network_interface" "playanicnmc" {
  name                = "example-terra-nicnmc"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "nmc-test-name"
    # Internal is the default name here, is not a required name.
    subnet_id                     = var.azure_subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.playaipnmc.id
    # If using a private IP address, omit the above line. If using a preexisting public Ip address, place it here.
  }
}

resource "azurerm_network_interface_security_group_association" "nsgnsgpairnmc" {
  network_interface_id      = azurerm_network_interface.playanicnmc.id
  network_security_group_id = azurerm_network_security_group.playansgea1.id
}

# Configuring the actual appliance.
resource "azurerm_linux_virtual_machine" "vmnmc" {
  name                = "example-terra-nmc"
  resource_group_name = var.resource_group
  location            = var.location
  size                = var.machine_size
  admin_username      = "testadministrator"
  disable_password_authentication = "false"
  admin_password      = "1p@ssword"
  # You may use a password or a public key in this window. Either are sufficient, and only used
  # during the deployment process, so we use the password here
  network_interface_ids = [
    azurerm_network_interface.playanicnmc.id,
  ]

  plan {
    # References a specific Nasuni machine in the Azure marketplace. These can be found under the
    # "Usage Information + Support" Field
    name      = "nasuni-nmc-2612-prod"
    # the "plan ID" field from the marketplace
    publisher = "nasunicorporation"
    product   = "nasuni-management-console"
  }

  provision_vm_agent = false
  allow_extension_operations = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    # References the same machine, using slightly different information, as the plan block above
    # These fields can be found by using the below command:
    # az vm image list --publisher nasunicorporation --all
    # They are also the same values as the above plan block, with the additional "version" field, which is the
    # number next to the title of the marketplace image in the WebClient
    publisher = "nasunicorporation"
    offer     = "nasuni-management-console"
    sku       = "nasuni-nmc-2612-prod"
    version   = "26.1.2"
  }
}


# Exports the public_IP that was created to the table. Feel free to delete both the data block and the output
# if using a private network setup or preexisting public IP address

data "azurerm_public_ip" "datablocknmc1" {
  name                = azurerm_public_ip.playaipnmc.name
  resource_group_name = azurerm_linux_virtual_machine.vmnmc.resource_group_name
}

output "instance_ip_addrnmc" {
  value = data.azurerm_public_ip.datablocknmc1.ip_address
}
