variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "allocation" {
  type = map(string)
  default = {
    "public" = "Static"
    "private" = "Dynamic"
  }
}


variable "nsg_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "name" {
 type = string 
}