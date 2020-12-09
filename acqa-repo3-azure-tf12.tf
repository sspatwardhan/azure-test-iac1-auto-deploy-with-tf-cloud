# Configure the Microsoft Azure Provider
provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you're using version 1.x, the "features" block is not allowed.
  # version = "=2.3"
  # client_id = "68f5ef66-456d-45c3-aa3c-54c542e15269"
  # client_secret = "qk5-B..Jp0J3YVNv44NZ~ocC~f6FK-EH6Y"
  # subscription_id = "734613be-a4f0-4fe5-9131-17614a0c896b"
  # tenant_id = "1b25d708-64d9-43ca-a6d4-7210952163ef"
  client_id       = "36334202-9263-4f4e-a489-3d00d2a5ac0a"
  client_secret   = "9iNPk.4U35JEQ7P_Hwy--9_vSu4bS3W00y"
  subscription_id = "954d2aa9-c87d-480b-be87-5f09e5cbedfc"
  tenant_id       = "fdc2b371-9276-4c4a-87ad-fd1cb11fdf47"
  features {}
}

terraform {
  required_providers {
    # random = {
    #     version = ">= 2.3"
    # }
    azurerm = {
      version = ">=2.7"
    }
  }
}

# Create a resource groups
# rg1
resource "azurerm_resource_group" "acqa-test-rg1" {
  name     = "acqa-test-rg1"
  location = "eastus"

  tags = {
    Name         = "acqa-test-rg1"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}


# Create virtual network in rg1
resource "azurerm_virtual_network" "acqa-test-vnet1" {
  name                = "acqa-test-vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name

  tags = {
    Name         = "acqa-test-vnet1"
    ACQAResource = "true"
    Owner        = "ACQA"
    Workspace    = terraform.workspace
  }

  subnet {
    name           = "subnet3"
    address_prefix = "<cidr>"
    security_group = "$${azurerm_network_security_group.<security_group_name>.id}"
  }
}

# Create subnet - doing this separately as it is attached to NIC below
resource "azurerm_subnet" "acqa-test-subnet1" {
  name                 = "acqa-test-subnet1"
  resource_group_name  = azurerm_resource_group.acqa-test-rg1.name
  virtual_network_name = azurerm_virtual_network.acqa-test-vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "acqa-test-publicip1" {
  name                = "acqa-test-publicip1"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name
  allocation_method   = "Dynamic"

  tags = {
    Name         = "acqa-test-publicip1"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}
resource "azurerm_public_ip" "acqa-test-publicip2" {
  name                = "acqa-test-publicip2"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name
  allocation_method   = "Dynamic"

  tags = {
    Name         = "acqa-test-publicip2"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}
resource "azurerm_public_ip" "acqa-test-publicip4" {
  name                = "acqa-test-publicip4"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name
  allocation_method   = "Dynamic"

  tags = {
    Name         = "acqa-test-publicip4"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "acqa-test-nsg1" {
  name                = "acqa-test-nsg1"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name         = "acqa-test-nsg1"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}

# Create network interface
resource "azurerm_network_interface" "acqa-test-nic1" {
  name                = "acqa-test-nic1"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name

  ip_configuration {
    name                          = "acqa-test-ipconfig1"
    subnet_id                     = azurerm_subnet.acqa-test-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.acqa-test-publicip1.id
  }

  tags = {
    Name         = "acqa-test-nic1"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "acqa-test-nisga1" {
  network_interface_id      = azurerm_network_interface.acqa-test-nic1.id
  network_security_group_id = azurerm_network_security_group.acqa-test-nsg1.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "acqa-test-storageaccount1" {
  name                     = "acqateststorageaccount1"
  resource_group_name      = azurerm_resource_group.acqa-test-rg1.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Name         = "acqa-test-storageaccount1"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
  min_tls_version = "TLS1_2"
}

# Create linux virtual machine
resource "azurerm_linux_virtual_machine" "acqa-test-lvm1" {
  name                  = "acqa-test-lvm1"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.acqa-test-rg1.name
  network_interface_ids = [azurerm_network_interface.acqa-test-nic1.id]
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "P@$$w0rd1234!"
  os_disk {
    name                 = "acqa-test-osdisk1"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  computer_name                   = "acqa-test-lvm1"
  disable_password_authentication = false

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.acqa-test-storageaccount1.primary_blob_endpoint
  }

  tags = {
    Name         = "acqa-test-lvm1"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}

# Create network interface
resource "azurerm_network_interface" "acqa-test-nic2" {
  name                = "acqa-test-nic2"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name

  ip_configuration {
    name                          = "acqa-test-ipconfig1"
    subnet_id                     = azurerm_subnet.acqa-test-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.acqa-test-publicip2.id
  }

  tags = {
    Name         = "acqa-test-nic2"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}

# Create network interface
resource "azurerm_network_interface" "acqa-test-nic3" {
  name                = "acqa-test-nic3"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name

  ip_configuration {
    name                          = "acqa-test-ipconfig1"
    subnet_id                     = azurerm_subnet.acqa-test-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.acqa-test-publicip4.id
  }

  tags = {
    Name         = "acqa-test-nic3"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}

# Create linux virtual machine
resource "azurerm_virtual_machine" "acqa-test-vm1" {
  name                  = "acqa-test-vm1"
  location              = azurerm_resource_group.acqa-test-rg1.location
  resource_group_name   = azurerm_resource_group.acqa-test-rg1.name
  network_interface_ids = [azurerm_network_interface.acqa-test-nic2.id]
  vm_size               = "Standard_DS1_v2"
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "acqa-test-osdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    Name         = "acqa-test-vm1"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}

#create windows_virtual_machine
resource "azurerm_windows_virtual_machine" "acqa-test-wvm1" {
  name                = "acqa-test-wvm1"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name
  location            = azurerm_resource_group.acqa-test-rg1.location
  size                = "Standard_F2"
  admin_username      = "mr.drift"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.acqa-test-nic3.id,
  ]

  os_disk {
    name                 = "acqa-test-osdisk3"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = {
    Name         = "acqa-test-wvm1"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
}


#create cosmosdb
resource "azurerm_cosmosdb_account" "acqa-test-cosmosdbaccount1" {
  name                      = "acqa-test-cosmosdbaccount1"
  location                  = azurerm_resource_group.acqa-test-rg1.location
  resource_group_name       = azurerm_resource_group.acqa-test-rg1.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = true
  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.acqa-test-rg1.location
    failover_priority = 0
  }

  tags = {
    Name         = "acqa-test-cosmosdbaccount1"
    ACQAResource = "true"
    Owner        = "ACQA"
  }
  ip_range_filter = "10.1.1.1/24"
}
resource "azurerm_cosmosdb_sql_database" "acqa-test-cosmossqldb1" {
  name                = "acqa-test-cosmossqldb1"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name
  account_name        = azurerm_cosmosdb_account.acqa-test-cosmosdbaccount1.name
}
resource "azurerm_cosmosdb_sql_container" "acqatestsqlcontainer1" {
  name                = "acqatestsqlcontainer1"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name
  account_name        = azurerm_cosmosdb_account.acqa-test-cosmosdbaccount1.name
  database_name       = azurerm_cosmosdb_sql_database.acqa-test-cosmossqldb1.name
  partition_key_path  = "/acqatestsqlcontainer1Id"
}

# Container Registry
resource "azurerm_container_registry" "acqatestcontainerregistry1" {
  name                     = "acqatestcontainerregistry1"
  resource_group_name      = azurerm_resource_group.acqa-test-rg1.name
  location                 = azurerm_resource_group.acqa-test-rg1.location
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = ["West Europe"]
}
resource "azurerm_management_lock" "acqatestcontainerregistry1" {
  name       = "azurerm_management_lock.acqatestcontainerregistry1"
  scope      = azurerm_container_registry.acqatestcontainerregistry1.id
  lock_level = "CanNotDelete"
  # azurerm_management_lock does not contain tags, and we cannot match them not unless the resource is deployed in the cloud.
  notes = "Cannot Delete Resource"
}
resource "azurerm_management_lock" "acqa-test-rg1" {
  name       = "azurerm_resource_group.acqa-test-rg1"
  scope      = azurerm_resource_group.acqa-test-rg1.id
  lock_level = "CanNotDelete"
  # azurerm_management_lock does not contain tags, and we cannot match them not unless the resource is deployed in the cloud.
  notes = "Cannot Delete Resource"
}