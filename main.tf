provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "website_rg" {
  name     = "website-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "website-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.website_rg.location
  resource_group_name = azurerm_resource_group.website_rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "website-subnet"
  resource_group_name  = azurerm_resource_group.website_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "website-nsg"
  location            = azurerm_resource_group.website_rg.location
  resource_group_name = azurerm_resource_group.website_rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "website-ip"
  resource_group_name = azurerm_resource_group.website_rg.name
  location            = azurerm_resource_group.website_rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "website-nic"
  location            = azurerm_resource_group.website_rg.location
  resource_group_name = azurerm_resource_group.website_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "website-vm"
  resource_group_name             = azurerm_resource_group.website_rg.name
  location                        = azurerm_resource_group.website_rg.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "20_04-lts"
  version   = "latest"
}

  tags = {
    environment = "dev"
  }
}

output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}
