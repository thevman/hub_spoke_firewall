provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  description = "The name of the resource group"
  default     = "myResourceGroup"
}

variable "location" {
  description = "The location/region where the resource group will be created"
  default     = "canadacentral"
}

variable "hub_vnet_name" {
  description = "The name of the hub virtual network"
  default     = "hubVnet"
}

variable "spoke_vnet_name" {
  description = "The name of the spoke virtual network"
  default     = "spokeVnet"
}

variable "firewall_name" {
  description = "The name of the firewall"
  default     = "myFirewall"
}