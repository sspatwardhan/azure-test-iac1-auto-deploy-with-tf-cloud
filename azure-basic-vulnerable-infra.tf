# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    # version = "=2.3"
    client_id = "68f5ef66-456d-45c3-aa3c-54c542e15269"
    client_secret = "qk5-B..Jp0J3YVNv44NZ~ocC~f6FK-EH6Y"
    subscription_id = "734613be-a4f0-4fe5-9131-17614a0c896b"
    tenant_id = "1b25d708-64d9-43ca-a6d4-7210952163ef"
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
        Name = "acqa-test-rg1"
        ACQAResource = "true"
        Owner = "ACQA"
    }
}

# Create virtual network in rg1
resource "azurerm_virtual_network" "acqa-test-vnet1" {
    name                = "acqa-test-vnet1"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.acqa-test-rg1.name

    tags = {
        Name = "acqa-test-vnet1"
        ACQAResource = "true"
        Owner = "ACQA"
    }
}

# Create subnet - doing this separately as it is attached to NIC below
resource "azurerm_subnet" "acqa-test-subnet1" {
    name                 = "acqa-test-subnet1"
    resource_group_name  = azurerm_resource_group.acqa-test-rg1.name
    virtual_network_name = azurerm_virtual_network.acqa-test-vnet1.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "acqa-test-publicip1" {
    name                         = "acqa-test-publicip1"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.acqa-test-rg1.name
    allocation_method            = "Dynamic"

    tags = {
        Name = "acqa-test-publicip1"
        ACQAResource = "true"
        Owner = "ACQA"
    }
}
resource "azurerm_public_ip" "acqa-test-publicip2" {
    name                         = "acqa-test-publicip2"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.acqa-test-rg1.name
    allocation_method            = "Dynamic"

    tags = {
        Name = "acqa-test-publicip2"
        ACQAResource = "true"
        Owner = "ACQA"
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
        Name = "acqa-test-nsg1"
        ACQAResource = "true"
        Owner = "ACQA"
    }
}

# Create network interface
resource "azurerm_network_interface" "acqa-test-nic1" {
    name                      = "acqa-test-nic1"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.acqa-test-rg1.name

    ip_configuration {
        name                          = "acqa-test-ipconfig1"
        subnet_id                     = azurerm_subnet.acqa-test-subnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.acqa-test-publicip1.id
    }

    tags = {
        Name = "acqa-test-nic1"
        ACQAResource = "true"
        Owner = "ACQA"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "acqa-test-nisga1" {
    network_interface_id      = azurerm_network_interface.acqa-test-nic1.id
    network_security_group_id = azurerm_network_security_group.acqa-test-nsg1.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "acqa-test-storageaccount1" {
    name                        = "acqateststorageaccount1"
    resource_group_name         = azurerm_resource_group.acqa-test-rg1.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        Name = "acqa-test-storageaccount1"
        ACQAResource = "true"
        Owner = "ACQA"
    }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "acqa-test-vm1" {
    name                  = "acqa-test-vm1"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.acqa-test-rg1.name
    network_interface_ids = [azurerm_network_interface.acqa-test-nic1.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "acqa-test-osdisk1"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    computer_name  = "acqa-test-vm1"
    admin_username = "acqa-test-user1"
    disable_password_authentication = true

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.acqa-test-storageaccount1.primary_blob_endpoint
    }

    #admin_ssh_key {
    #username   = "acqa-test-user1"
    #public_key = file("~/.ssh/id_rsa.pub")
  }

    tags = {
        Name = "acqa-test-vm1"
        ACQAResource = "true"
        Owner = "ACQA"
    }
}

# Create SQL Server
resource "azurerm_sql_server" "acqa-test-sqlserver1" {
  name                         = "acqa-test-sqlserver1"
  resource_group_name          = azurerm_resource_group.acqa-test-rg1.name
  location                     = azurerm_resource_group.acqa-test-rg1.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"

  tags = {
        Name = "acqa-test-sqlserver1"
        ACQAResource = "true"
        Owner = "ACQA"
    }
}

#Create SQL DB
resource "azurerm_sql_database" "acqa-test-sqldb1" {
  name                = "acqa-test-sqldb1"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name
  location            = azurerm_resource_group.acqa-test-rg1.location
  server_name         = azurerm_sql_server.acqa-test-sqlserver1.name

  tags = {
        Name = "acqa-test-sqldb1"
        ACQAResource = "true"
        Owner = "ACQA"
    }

  threat_detection_policy {
    state = "Disabled"
  }
}

resource "azurerm_sql_firewall_rule" "acqa-test-firewallrule1" {
  name                = "acqa-test-firewallrule1"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name
  server_name         = azurerm_sql_server.acqa-test-sqlserver1.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}


# Create pgsql server and db
resource "azurerm_postgresql_server" "acqa-test-pgsqlserver1" {
  name                = "acqa-test-pgsqlserver1"
  location            = azurerm_resource_group.acqa-test-rg1.location
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement_enabled      = false

  tags = {
        Name = "acqa-test-pgsqlserver1"
        ACQAResource = "true"
        Owner = "ACQA"
    }
}

resource "azurerm_postgresql_database" "acqa-test-pgsqldb1" {
  name                = "acqa-test-pgsqldb1"
  resource_group_name = azurerm_resource_group.acqa-test-rg1.name
  server_name         = azurerm_postgresql_server.acqa-test-pgsqlserver1.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}