#########################################################
### Defines Azure Resource Manager Terraform Provider ###
#########################################################
provider "azurerm" {
    version = "2.9.0"
    features {}
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
######### Creates Azure Storage Account #################
#########################################################

resource "azurerm_storage_account" "aci-storage" {
  name = "mvmsta${lower(random_string.prefix.result)}"
  resource_group_name = azurerm_resource_group.rg-cooldad-mvm.name
  location = azurerm_resource_group.rg-cooldad-mvm.location
  account_tier = "Premium"
  account_replication_type = "LRS"
  account_kind = "FileStorage"

}

#########################################################
######### Creates 100GB Azure File Share#################
#########################################################
resource "azurerm_storage_share" "aci-share" {
  name = "pvc-mc-001"
  storage_account_name = azurerm_storage_account.aci-storage.name
  quota = 100
}

#########################################################
######### Creates Azure Container Instance Group ########
########## 1 Minecraft Container is Created #############
########### 1 CPU and 2 GB Memory Allocated #############
#########################################################
resource "azurerm_container_group" "cooldad-mvm-cg" {
  name = "mvmaci${lower(random_string.prefix.result)}"
  location = azurerm_resource_group.rg-cooldad-mvm.location
  resource_group_name = azurerm_resource_group.rg-cooldad-mvm.name
  ip_address_type = "public"
  dns_name_label = "aci${lower(random_string.prefix.result)}"
  os_type = "Linux"
  
  container {
    name = "minecraft"
    image = "docker.io/cooltechdad/minecraft-bds:0.5" 
    cpu = "1"
    memory = "2"

    ports {
      port = "19132"
      protocol = "UDP"
    }

    environment_variables = {
      "debug" = "true",
      "bds_version" = "1.18.2.03",
      "eula" = "TRUE",
      "level_name" = "Bedrock level",
      "gamemode" = "creative",
      "difficulty" = "normal",
      "allow_cheats" = "false",
      "max_players" = "1000",
      "server_authoritative_movement" = "server-auth-with-rewind"
    }

    volume {
      name = "pv001"
      mount_path = "/data"
      storage_account_name = azurerm_storage_account.aci-storage.name
      storage_account_key = azurerm_storage_account.aci-storage.primary_access_key
      share_name = azurerm_storage_share.aci-share.name
    }
  }
  
  depends_on = [
    azurerm_storage_account.aci-storage,
    azurerm_storage_share.aci-share
  ]
}
#########################################################
########### Creates some useful outputs #################
###### this provides ease of use for connectivity #######
#########################################################
output "container_ip_address" {
  value = azurerm_container_group.cooldad-mvm-cg.ip_address
}
output "contain_dns_name" {
  value = azurerm_container_group.cooldad-mvm-cg.dns_name_label
}