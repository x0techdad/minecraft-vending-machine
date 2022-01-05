provider "azurerm" {
    version = "2.9.0"
    features {}
}


resource "azurerm_resource_group" "useast-minecraftaks-rg" {
  name = var.resource_group_name
  location = var.resource_location
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
     



   } 


} 