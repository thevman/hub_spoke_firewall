terraform {
  required_version = ">=1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.61.0"
    }
  }
  backend "azurerm" {

  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  use_oidc                   = true
}
provider "azurerm" {
  features {}
  alias                      = "dns_spoke"
  subscription_id            = var.dns_subscription_id
  skip_provider_registration = true
  use_oidc                   = true
}
