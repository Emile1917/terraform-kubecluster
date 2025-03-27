variable "DEFAULT_RESOURCE_GROUP_NAME" {
  type    = string
  default = null
}

variable "LOCATION" {
  description = "Location of the network"
  default     = "eastus"
}

variable "DOMAIN_NAME" {
  type    = string
  default = "please_set_the_domain"
}

variable "master" {
  type    = string
  default = "kube-controlplane"
}

variable "worker" {
  type = object({
    name    = string
    numbers = number
  })

  default = {
    name    = "node"
    numbers = 2
  }
}

variable "adminuser" {
  type    = string
  default = "azureuser"
}