provider "azurerm" {
    version = "2.9.0"
    features {}
}

terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "2.3.0"
    }
  }
}

resource "random_string" "dns_prefix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "useast-minecraftaks-rg" {
  name = var.resource_group_name
  location = var.resource_location
}

resource "azurerm_virtual_network" "useast-aks-vnet" {
    name = var.minecraftaks_vnet_name
    address_space = ["192.168.0.0/16"]
    location = azurerm_resource_group.useast-minecraftaks-rg.location
    resource_group_name = azurerm_resource_group.useast-minecraftaks-rg.name
}


resource "azurerm_subnet" "useast-aks-subnet" {
    name                 = var.minecraftaks_subnet_name
    resource_group_name  = azurerm_resource_group.useast-minecraftaks-rg.name
    address_prefixes     = ["192.168.1.0/24"]
    virtual_network_name = azurerm_virtual_network.useast-aks-vnet.name
}



resource "azurerm_kubernetes_cluster" "useast-minecraft-aks" {
  name = var.useast-minecraft-aksname
  location = azurerm_resource_group.useast-minecraftaks-rg.location
  resource_group_name  = azurerm_resource_group.useast-minecraftaks-rg.name
  dns_prefix = var.dns_prefix
  kubernetes_version = var.kube_version
  
  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
    }
   default_node_pool {
     name = "default"
     node_count = 2
     vm_size = "Standard_DS2_v5"
     os_disk_size_gb = "30"
     vnet_subnet_id = azurerm_subnet.useast-aks-subnet.id
   } 
   
   identity {
     type = "SystemAssigned"
   }
   
   network_profile {
     load_balancer_sku = "standard"
     network_plugin = "kubenet"
   }

}



