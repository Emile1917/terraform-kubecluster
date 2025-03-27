variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "account_tier" {
  type = string
  default = "Standard"
}

variable "account_replication_type" {
  description = "The replication type for the storage account (e.g., LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS" # Optional: Set a default value if applicable
}