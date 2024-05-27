variable "resource_group_name" {
  description = "The name of the resource group"
  default     = "myResourceGroup"
  type        = string
}

variable "location" {
  description = "The location/region where the resource group will be created"
  default     = "canadacentral"
  type        = string
}

variable "hub_vnet_name" {
  description = "The name of the hub virtual network"
  default     = "hubVnet"
  type        = string
}

variable "spoke_vnet_name" {
  description = "The name of the spoke virtual network"
  default     = "spokeVnet"
  type        = string
}

variable "firewall_name" {
  description = "The name of the firewall"
  default     = "myFirewall"
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP address"
  default     = "myPublicIP"
  type        = string
}

variable "spoke_address_space" {
  description = "Address space for the spoke virtual network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "spoke_subnet_address_prefixes" {
  description = "Address prefixes for the spoke subnet"
  type        = list(string)
  default     = ["10.1.0.0/24"]
}

variable "firewall_policy_name" {
  description = "The name of the firewall policy"
  default     = "myFirewallPolicy"
  type        = string

}