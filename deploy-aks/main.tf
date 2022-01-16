c#########################################################
### Defines Azure Resource Manager Terraform Provider ###
#########################################################
provider "azurerm" {
    version = "2.9.0"
    features {}
}
#########################################################
##### Defines the Random string generator Provider ######
#########################################################
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "2.3.0"
    }
  }
}
#########################################################
##### Defines the Random string generator Provider ######
#########################################################
resource "random_string" "prefix" {
  length           = 6
  special          = false 
}

#########################################################
######### Creates Azure Resource Group ##################
#########################################################
resource "azurerm_resource_group" "rg-cooldad-mvm" {
  name = "rg-cooldad-mvm"
  location = var.resource_location
}

#########################################################
######### Creates Azure Virtual Network #################
#########################################################
resource "azurerm_virtual_network" "mvm-aks-vnet" {
    name = "mvm-aks-vnet"
    address_space = ["192.168.0.0/16"]
    location = azurerm_resource_group.rg-cooldad-mvm.location
    resource_group_name = azurerm_resource_group.rg-cooldad-mvm.name
}


#########################################################
######### Creates Azure Subnet tied to VNET #############
#########################################################
resource "azurerm_subnet" "mvm-aks-subnet" {
    name                 = "mvm-aks-subnet"
    resource_group_name  = azurerm_resource_group.rg-cooldad-mvm.name
    address_prefixes     = ["192.168.1.0/24"]
    virtual_network_name = azurerm_virtual_network.mvm-aks-vnet.name
}


#########################################################
######### Creates Azure Kubernetes Cluster ##############
######### 1 Minecraft Container is Created ##############
########## 2 CPU and 8 GB Memory Allocated ##############
#########################################################
resource "azurerm_kubernetes_cluster" "mvm-aks" {
  name = "mvmaks${lower(random_string.prefix.result)}"
  location = azurerm_resource_group.rg-cooldad-mvm.location
  resource_group_name  = azurerm_resource_group.rg-cooldad-mvm.name
  dns_prefix = "mvmaks${lower(random_string.prefix.result)}dns"
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
     vm_size = "standard_d2s_v4"
     os_disk_size_gb = "30"
     vnet_subnet_id = azurerm_subnet.mvm-aks-subnet.id
   } 
   
   identity {
     type = "SystemAssigned"
   }
   
   network_profile {
     load_balancer_sku = "standard"
     network_plugin = "kubenet"
   }

}



