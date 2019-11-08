terraform {
  backend "local" {
  }
}

#Declare Variables
variable "ssh_source_ip" {
  type = string
}

variable "ssh_pub_key" {
  type = string
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "wtw-terraform-group" {
    name     = "WTW-RG"
    location = "westus"
}

# Create virtual network
resource "azurerm_virtual_network" "wtw-terraform-network" {
    name                = "WTW-Vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westus"
    resource_group_name = azurerm_resource_group.wtw-terraform-group.name
}

# Create subnet
resource "azurerm_subnet" "wtw-terraform-subnet" {
    name                 = "WTW-Subnet"
    resource_group_name  = azurerm_resource_group.wtw-terraform-group.name
    virtual_network_name = azurerm_virtual_network.wtw-terraform-network.name
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "wtw-terraform-publicip" {
    name                         = "WTW-PublicIP"
    location                     = "westus"
    resource_group_name          = azurerm_resource_group.wtw-terraform-group.name
    allocation_method            = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "wtw-terraform-nsg" {
    name                = "WTW-NetworkSecurityGroup"
    location            = "westus"
    resource_group_name = azurerm_resource_group.wtw-terraform-group.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = var.ssh_source_ip
        destination_address_prefix = "*"
    }
}

# Create network interface
resource "azurerm_network_interface" "wtw-terraform-nic" {
    name                      = "WTW-NIC"
    location                  = "westus"
    resource_group_name       = azurerm_resource_group.wtw-terraform-group.name
    network_security_group_id = azurerm_network_security_group.wtw-terraform-nsg.id

    ip_configuration {
        name                          = "WTW-NicConfiguration"
        subnet_id                     = azurerm_subnet.wtw-terraform-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.wtw-terraform-publicip.id
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "wtw-terraform-vm" {
    name                  = "WTW-VM"
    location              = "westus"
    resource_group_name   = azurerm_resource_group.wtw-terraform-group.name
    network_interface_ids = [azurerm_network_interface.wtw-terraform-nic.id]
    vm_size               = "Standard_D1"

    storage_os_disk {
        name              = "WTW-VM-OsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_data_disk {
        name              = "WTW-VM-DataDisk"
        managed_disk_type = "Standard_LRS"
        create_option     = "Empty"
        lun               = 0
        disk_size_gb      = "10"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "WTWvm"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = var.ssh_pub_key
        }
    }
}