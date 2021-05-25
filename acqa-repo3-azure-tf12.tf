# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    # version = "=2.3"
    client_id = "68f5ef66-456d-45c3-aa3c-54c542e15269"
    client_secret = "qk5-B..Jp0J3YVNv44NZ~ocC~f6FK-EH6Y"
    subscription_id = "734613be-a4f0-4fe5-9131-17614a0c896b"
    tenant_id = "1b25d708-64d9-43ca-a6d4-7210952163ef"
    # client_id = "36334202-9263-4f4e-a489-3d00d2a5ac0a"
    # client_secret = "9iNPk.4U35JEQ7P_Hwy--9_vSu4bS3W00y"
    # subscription_id = "954d2aa9-c87d-480b-be87-5f09e5cbedfc"
    # tenant_id = "fdc2b371-9276-4c4a-87ad-fd1cb11fdf47"
    # client_id       = "0382e62d-0ef4-4647-99a4-e61b4c94d022"
    # client_secret   = "0W0UNq~5BZd99NxLf4-D3K.w6nMZm5P.CO"
    # subscription_id = "c6ad982d-08a6-43b1-b32a-0fd82da52d31"
    # tenant_id       = "93e9cfac-b18c-4c8f-9c97-7b88b3c002f2"
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
# resource "azurerm_virtual_network" "acqa-test-vnet1" {
#     name                = "acqa-test-vnet1"
#     address_space       = ["10.0.0.0/16"]
#     location            = "eastus"
#     resource_group_name = azurerm_resource_group.acqa-test-rg1.name

#     tags = {
#         Name = "acqa-test-vnet1"
#         ACQAResource = "true"
#         Owner = "ACQA"
#         Workspace = terraform.workspace
#     }
# }

# # Create subnet - doing this separately as it is attached to NIC below
# resource "azurerm_subnet" "acqa-test-subnet1" {
#     name                 = "acqa-test-subnet1"
#     resource_group_name  = azurerm_resource_group.acqa-test-rg1.name
#     virtual_network_name = azurerm_virtual_network.acqa-test-vnet1.name
#     address_prefixes       = ["10.0.1.0/24"]
# }

# # Create public IPs
# resource "azurerm_public_ip" "acqa-test-publicip1" {
#     name                         = "acqa-test-publicip1"
#     location                     = "eastus"
#     resource_group_name          = azurerm_resource_group.acqa-test-rg1.name
#     allocation_method            = "Dynamic"

#     tags = {
#         Name = "acqa-test-publicip1"
#         ACQAResource = "true"
#         Owner = "ACQA"
#     }
# }
# resource "azurerm_public_ip" "acqa-test-publicip2" {
#     name                         = "acqa-test-publicip2"
#     location                     = "eastus"
#     resource_group_name          = azurerm_resource_group.acqa-test-rg1.name
#     allocation_method            = "Dynamic"

#     tags = {
#         Name = "acqa-test-publicip2"
#         ACQAResource = "true"
#         Owner = "ACQA"
#     }
# }
# resource "azurerm_public_ip" "acqa-test-publicip4" {
#     name                         = "acqa-test-publicip4"
#     location                     = "eastus"
#     resource_group_name          = azurerm_resource_group.acqa-test-rg1.name
#     allocation_method            = "Dynamic"

#     tags = {
#         Name = "acqa-test-publicip4"
#         ACQAResource = "true"
#         Owner = "ACQA"
#     }
# }

# # Create Network Security Group and rule
# resource "azurerm_network_security_group" "acqa-test-nsg1" {
#     name                = "acqa-test-nsg1"
#     location            = "eastus"
#     resource_group_name = azurerm_resource_group.acqa-test-rg1.name
    
#     security_rule {
#         name                       = "SSH"
#         priority                   = 1001
#         direction                  = "Inbound"
#         access                     = "Allow"
#         protocol                   = "tcp"
#         source_port_range          = "*"
#         destination_port_range     = "*"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#     }

#     tags = {
#         Name = "acqa-test-nsg1"
#         ACQAResource = "true"
#         Owner = "ACQA"
#     }
# }

# # Create network interface
# resource "azurerm_network_interface" "acqa-test-nic1" {
#     name                      = "acqa-test-nic1"
#     location                  = "eastus"
#     resource_group_name       = azurerm_resource_group.acqa-test-rg1.name

#     ip_configuration {
#         name                          = "acqa-test-ipconfig1"
#         subnet_id                     = azurerm_subnet.acqa-test-subnet1.id
#         private_ip_address_allocation = "Dynamic"
#         public_ip_address_id          = azurerm_public_ip.acqa-test-publicip1.id
#     }

#     tags = {
#         Name = "acqa-test-nic1"
#         ACQAResource = "true"
#         Owner = "ACQA"
#     }
# }

# # Connect the security group to the network interface
# resource "azurerm_network_interface_security_group_association" "acqa-test-nisga1" {
#     network_interface_id      = azurerm_network_interface.acqa-test-nic1.id
#     network_security_group_id = azurerm_network_security_group.acqa-test-nsg1.id
# }

# # Create storage account for boot diagnostics
# resource "azurerm_storage_account" "acqateststrgaccount1" {
#     name                        = "acqateststrgaccount1"
#     resource_group_name         = azurerm_resource_group.acqa-test-rg1.name
#     location                    = "eastus"
#     account_tier                = "Standard"
#     account_replication_type    = "LRS"

#     tags = {
#         Name = "acqateststrgaccount1"
#         ACQAResource = "true"
#         Owner = "ACQA"
#     }
# }


# # Create network interface
# resource "azurerm_network_interface" "acqa-test-nic2" {
#     name                      = "acqa-test-nic2"
#     location                  = "eastus"
#     resource_group_name       = azurerm_resource_group.acqa-test-rg1.name

#     ip_configuration {
#         name                          = "acqa-test-ipconfig1"
#         subnet_id                     = azurerm_subnet.acqa-test-subnet1.id
#         private_ip_address_allocation = "Dynamic"
#         public_ip_address_id          = azurerm_public_ip.acqa-test-publicip2.id
#     }

#     tags = {
#         Name = "acqa-test-nic2"
#         ACQAResource = "true"
#         Owner = "ACQA"
#     }
# }


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "acqa-test-kvault1" {
  name                       = "acqa-test-kvault1"
  location                   = azurerm_resource_group.acqa-test-rg1.location
  resource_group_name        = azurerm_resource_group.acqa-test-rg1.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7
  purge_protection_enabled    = true
#   network_acls {
#     default_action = "Deny"
#     bypass         = "AzureServices"
#   }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "setissuers",
      "update",
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
      "list"
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set",
    ]
  }
}

resource "azurerm_key_vault_certificate" "acqa-test-kvault1-cert1" {
  name         = "acqa-test-kvault1-cert1"
  key_vault_id = azurerm_key_vault.acqa-test-kvault1.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["qa.accurics.com", "automate.and.chill"]
      }

      subject            = "CN=hello-world"
      validity_in_months = 12
    }
  }
}

resource "azurerm_key_vault_key" "acqa-test-kvault1-key1" {
  name         = "acqa-test-kvault1-key1-certificate"
  key_vault_id = azurerm_key_vault.acqa-test-kvault1.id
  key_type     = "RSA"
  key_size     = 2048
  expiration_date = "2050-01-01T00:00:00Z"
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_key_vault_secret" "acqa-test-kvault1-secret1" {
  name         = "acqa-test-kvault1-secret1"
  value        = "szechuan"
#   content_type = "application/x-pkcs12"
  key_vault_id = azurerm_key_vault.acqa-test-kvault1.id
  expiration_date = "2050-01-01T00:00:00Z"
}
