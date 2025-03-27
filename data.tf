data "azurerm_resource_group" "rg" {
  count = var.DEFAULT_RESOURCE_GROUP_NAME == null ? 0 : 1
  name  = var.DEFAULT_RESOURCE_GROUP_NAME
}