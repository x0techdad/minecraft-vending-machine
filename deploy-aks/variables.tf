variable "resource_group_name" {
  description = "Please input resource group name"
}
variable "resource_location" {
  description = "Please input resource location"
}
variable "useast-minecraft-aksname" {
  default = "useast-minecraft-aks"
}
variable "dns_prefix" {
  description = "Please enter a DNS prefix for this AKS Cluster"
}
variable "kube_version" {
  type = string
  default = "1.20.9"
}
variable "admin_username" {
  description = "Please enter the usernameyou would like for the for the AKS cluster"
}

variable "minecraftaks_vnet_name" {
  default = "useast-minecraftaks-vnet"
}

variable "minecraftaks_subnet_name" {
  default = "useast-minecraftaks-subnet"
}
variable "ssh_public_key" {
  default = "id_rsa.pub"
}
