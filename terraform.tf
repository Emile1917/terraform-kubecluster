terraform {

  required_version = ">=1.0"

  backend "azurerm" {

  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.24.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }

  }
}

 # if: github.ref == 'refs/heads/"main"' && github.event_name == 'push'