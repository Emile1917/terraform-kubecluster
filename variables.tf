variable "DEFAULT_RESOURCE_GROUP_NAME" {
  type = string
  default = null
}

variable "location" {
  description = "Location of the network"
  default     = "eastus"
}

variable "DOMAIN_NAME" {
  type = string
  default = "please_set_the_domain"
}

variable "master" {
  type = string
  default = "kube-controlplane"
}

variable "worker" {
  type = object({
    name = string
    numbers =  number
  })

  default = {
    name = "node"
    numbers = 2
  }
}

variable "adminuser" {
  type = string
  default = "azureuser"
}

variable "storage_account_name" {
  type = string
  default = "kubecluster"
}

variable "metadata_host" {
  type = string
  default = ""
}

variable "key" {
  type = string
  default = ""
}