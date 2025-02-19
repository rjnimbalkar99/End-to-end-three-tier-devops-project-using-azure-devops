terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-backend"
    storage_account_name = "terraformbackend789"
    container_name       = "tfstate"
    key                 = "terraform.tfstate"
  }
}