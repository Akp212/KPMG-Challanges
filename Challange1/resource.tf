resource "azurerm_resource_group" "challange" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_virtual_network" "VN" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.challange.location
  resource_group_name = azurerm_resource_group.challange.name
}
resource "azurerm_subnet" "web-subnet" {
  name                 = var.web_subnet_name
  resource_group_name  = azurerm_resource_group.challange.name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "app-subnet" {
  name                 = var.app_subnet_name
  resource_group_name  = azurerm_resource_group.challange.name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet" "db-subnet" {
  name                 = var.db_subnet_name
  resource_group_name  = azurerm_resource_group.challange.name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "pip"
  location            = azurerm_resource_group.challange.location
  resource_group_name = azurerm_resource_group.challange.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "web-nsg" {
  name = var.web_nsg_name
  location            = azurerm_resource_group.challange.location
  resource_group_name = azurerm_resource_group.challange.name
     security_rule {
    name                       = "ssh-rule-1"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }

  security_rule {
    name                       = "ssh-rule-2"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_address_prefix      = "192.168.3.0/24"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
}
resource "azurerm_subnet_network_security_group_association" "web-nsg-subnet" {
  subnet_id                 = var.web_subnet_name
  network_security_group_id = azurerm_network_security_group.web-nsg.id
}
resource "azurerm_availability_set" "web_availabilty_set" {
  name                = "web_availabilty_set"
  location            = var.location
  resource_group_name = var.resource_group
}
resource "azurerm_network_interface" "web_nic" {
  name                = var.web_network_interface_name
  location            = azurerm_resource_group.challange.location
  resource_group_name = azurerm_resource_group.challange.name

  ip_configuration {
    name                          = "web"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}
resource "azurerm_linux_virtual_machine" "web-vm" {
  name                = var.web_virtual_machine_name
  location            = azurerm_resource_group.challange.location
  resource_group_name = azurerm_resource_group.challange.name
  availability_set_id = azurerm_availability_set.web_availabilty_set.id

  size                = "Standard_F2"
  admin_username      = "webadmin"
  admin_password = "Password@123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.web_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_availability_set" "app_availabilty_set" {
  name                = "app_availabilty_set"
  location            = var.location
  resource_group_name = var.resource_group
}
resource "azurerm_network_interface" "app_nic" {
  name                = var.app_network_interface_name
  location            = azurerm_resource_group.challange.location
  resource_group_name = azurerm_resource_group.challange.name

  ip_configuration {
    name                          = "app"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_security_group" "app-nsg" {
  #depends_on=[azurerm_resource_group.network-rg]
  name = var.app_nsg_name
  location            = azurerm_resource_group.challange.location
  resource_group_name = azurerm_resource_group.challange.name
  security_rule {
        name = "ssh-rule-1"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_address_prefix = "192.168.1.0/24"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "22"
    }
    
    security_rule {
        name = "ssh-rule-2"
        priority = 101
        direction = "Outbound"
        access = "Allow"
        protocol = "Tcp"
        source_address_prefix = "192.168.1.0/24"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "22"
    }
}
resource "azurerm_subnet_network_security_group_association" "app-nsg-subnet" {
  subnet_id                 = var.app_subnet_name
  network_security_group_id = azurerm_network_security_group.app-nsg.id
}
resource "azurerm_linux_virtual_machine" "app-vm" {
  name                = var.app_virtual_machine_name
  location            = azurerm_resource_group.challange.location
  resource_group_name = azurerm_resource_group.challange.name
  availability_set_id = azurerm_availability_set.app_availabilty_set.id

  size                = "Standard_F2"
  admin_username      = "appadmin"
  admin_password = "Password@123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_network_security_group" "db-nsg" {
  name = var.db_nsg_name
  location            = azurerm_resource_group.challange.location
  resource_group_name = azurerm_resource_group.challange.name
    security_rule {
        name = "ssh-rule-1"
        priority = 101
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_address_prefix = "192.168.2.0/24"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "3306"
    }
    
    security_rule {
        name = "ssh-rule-2"
        priority = 102
        direction = "Outbound"
        access = "Allow"
        protocol = "Tcp"
        source_address_prefix = "192.168.2.0/24"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "3306"
    }
}
resource "azurerm_subnet_network_security_group_association" "db-nsg-subnet" {
  subnet_id                 = var.db_subnet_id
  network_security_group_id = azurerm_network_security_group.db-nsg.id
}
resource "azurerm_sql_server" "primary" {
    name = var.primary_database
    location            = azurerm_resource_group.challange.location
    resource_group_name = azurerm_resource_group.challange.name
    version = var.primary_database_version
    administrator_login = "user"
    administrator_login_password = "Password@123"
}

resource "azurerm_sql_database" "db" {
  name                = "db"
  location            = azurerm_resource_group.challange.location
  resource_group_name = azurerm_resource_group.challange.name
  server_name         = azurerm_sql_server.primary.name
}
