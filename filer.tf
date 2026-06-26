# Note: On a number of these resources, a name field is configured. These may be extrapolated to variables (in a
# similar manner to resource group and location) if desired, but remain strings here. Note that the extrapolation to
# variables does *NOT* apply to the name config in the plan block (nasuni-nea-9124-prod); that should remain as a string.


#### Note: Azurerm_public_Ip is only necessary if if you want admin- and/or end-users
#### to connect to your EA using a public IP. If connections will be purely through
#### the instance's auto-provided private IP, this block may be omitted. Such an omission has not been tested
#### You may also use your pre-created public IPs for your vm. In this case, delete the public_ip block
####

resource "azurerm_public_ip" "playaipea1" {
  name                = "example-terra-ipea1"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Dynamic"
}

# We create a fresh network interface for each appliance.
resource "azurerm_network_interface" "playanicea1" {
  name                = "example-terra-nicea1"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "test-name"
    # Internal is the default name here, is not a required name.
    subnet_id                     = var.azure_subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.playaipea1.id
    # If using a private IP address, omit the above line. If using a preexisting public Ip address, place it here.
  }
}

# In the Azure web client, a security group gets created by default when setting up a Nasuni Edge Appliance.
# A similar security group is configured below.
#NOTE: This security group allows public access to the Edge from the Internet. You will likely want to restrict access via the source_port_range and other fields.
resource "azurerm_network_security_group" "playansgea1" {
  name                = "example-terraform-nsgea1"
  location            = var.location
  resource_group_name = var.resource_group
}

# Rule allowing Admin access to the Filer
resource "azurerm_network_security_rule" "azureadminruleea1" {
  name                        = "Admin-terraform-ea1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.playansgea1.name
}

# Rule allowing access via SSH for Nasuni Support.
resource "azurerm_network_security_rule" "azuresupporruleea1" {
  name                        = "default-allow-ssh-terraform-ea1"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.playansgea1.name
}

# Rule for allowing Web Access
resource "azurerm_network_security_rule" "azurewebruleea1" {
  name                        = "WebAccess-terraform-ea1"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.playansgea1.name
}

resource "azurerm_network_interface_security_group_association" "nsgnsgpairea1" {
  network_interface_id      = azurerm_network_interface.playanicea1.id
  network_security_group_id = azurerm_network_security_group.playansgea1.id
}

# Configuring the actual appliance.
resource "azurerm_linux_virtual_machine" "vmea1" {
  name                = "example-terra-ea1"
  resource_group_name = var.resource_group
  location            = var.location
  size                = var.machine_size
  admin_username      = "testadministrator"
  disable_password_authentication = "false"
  admin_password      = "1p@ssword"
  # You may use a password or a public key in this window. Either are sufficient, and only used
  # during the deployment process, so we use the password here
  network_interface_ids = [
    azurerm_network_interface.playanicea1.id,
  ]

  plan {
    # References a specific Nasuni machine in the Azure marketplace. These can be found under the
    # "Usage Information + Support" Field
    name      = "nasuni-nea-9124-prod"
    # the "plan ID" field from the marketplace
    publisher = "nasunicorporation"
    product   = "nasuni-nea-90-prod"
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
    offer     = "nasuni-nea-90-prod"
    sku       = "nasuni-nea-9124-prod"
    version   = "9.12.4"
  }
}

# Creating disks for Edge appliance
resource "azurerm_managed_disk" "cachediskea1" {
  name                 = "example-terra-cacheea1"
  location             = var.location
  resource_group_name  = var.resource_group
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.cache_size
}

# Create the Copy on write disk is not strictly necessary, but we do it here.
resource "azurerm_managed_disk" "cowdiskea1" {
  name                 = "example-terra-cowea1"
  location             = var.location
  resource_group_name  = var.resource_group
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.cow_size
}

# Attaches the cache disk to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "cachediskattachea1" {
  managed_disk_id    = azurerm_managed_disk.cachediskea1.id
  virtual_machine_id = azurerm_linux_virtual_machine.vmea1.id
  lun                = "10"
  caching            = "ReadWrite"
}

# Attaches the COW disk to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "cowdiskattachea1" {
  managed_disk_id    = azurerm_managed_disk.cowdiskea1.id
  virtual_machine_id = azurerm_linux_virtual_machine.vmea1.id
  lun                = "11"
  caching            = "ReadWrite"
}

# Exports the public_IP that was created to the table. Feel free to delete both the data block and the output
# if using a private network setup or preexisting public IP address

data "azurerm_public_ip" "datablockea1" {
  name                = azurerm_public_ip.playaipea1.name
  resource_group_name = azurerm_linux_virtual_machine.vmea1.resource_group_name
}

output "instance_ip_addrea1" {
  value = data.azurerm_public_ip.datablockea1.ip_address
}