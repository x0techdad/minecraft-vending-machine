#########################################################
##### Defines required providers ########################
#########################################################
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "2.3.0"
    }

    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.91.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#########################################################
##### Defines random string properties ##################
#########################################################
resource "random_string" "prefix" {
  length           = 4
  special          = false 
}

#########################################################
######### Creates Azure Resource Group ##################
#########################################################
resource "azurerm_resource_group" "rg-cooldad-mvm" {
  name = "rg-cooldad-mvm-aks"
  location = var.resource_location
}

#########################################################
######### Creates Azure Kubernetes Cluster ##############
################### Single node pool ####################
########## 2 CPU and 8 GB Memory Allocated ##############
#########################################################
resource "azurerm_kubernetes_cluster" "mvm-aks" {
  name = "akscooldadmvm${lower(random_string.prefix.result)}"
  location = azurerm_resource_group.rg-cooldad-mvm.location
  resource_group_name  = azurerm_resource_group.rg-cooldad-mvm.name
  dns_prefix = "cooldadmvm${lower(random_string.prefix.result)}dns"
  kubernetes_version = var.kube_version
  
   default_node_pool {
     name = "default"
     node_count = 1
     vm_size = "standard_b4ms"
     os_disk_size_gb = "30"
   } 
   
   identity {
     type = "SystemAssigned"
   }
   
   network_profile {
     load_balancer_sku = "standard"
     network_plugin = "kubenet"
   }

}
#########################################################
######### Utilizing the Terraform provisioner ###########
#########   This will authenticate into AKS ##############
#########      create persistent storage   ##############
###########    create minecraft server       ############
#########################################################
### resource "null_resource" "provision" {
#### provisioner "local-exec" {
#### command = "az aks get-credentials -n ${azurerm_kubernetes_cluster.mvm-aks.name} -g ${azurerm_resource_group.rg-cooldad-mvm.name}"
####  }
####  provisioner "local-exec" {
####    command = "kubectl apply -f azure_files_pvc.yaml"
####  }
####  provisioner "local-exec" {
####    command = "kubectl apply -f minecraft-bds.yaml"
####  }
####  depends_on = [azurerm_kubernetes_cluster.mvm-aks]
####}
#########################################################
########### Creates some useful outputs #################
###### this provides ease of use for connectivity #######
#########################################################
output "aks_name" {
  value = azurerm_kubernetes_cluster.mvm-aks.name
}

