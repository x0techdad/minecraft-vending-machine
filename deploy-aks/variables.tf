variable "resource_location" {
  description = "Please input resource location"
}
variable "kube_version" {
  type = string
  default = "1.20.9"
}
variable "admin_username" {
  description = "Please enter the usernameyou would like for the for the AKS cluster"
}

variable "ssh_public_key" {
  default = "id_rsa.pub"
}
