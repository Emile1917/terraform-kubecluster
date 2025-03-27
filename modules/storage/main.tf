locals {
  rg_name = var.rg_name
  rg_location = var.rg_location
}


# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = local.rg_name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = local.rg_location
  resource_group_name      = local.rg_name
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}