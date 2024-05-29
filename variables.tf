
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

variable "firewall_policy_name" {
  description = "The name of the firewall policy"
  default     = "myFirewallPolicy"
  type        = string

}

// Spoke variables
variable "spoke1_resource_group_name" {
  description = "The name of the spoke resource group"
  default     = "mySpoke1ResourceGroup"
  type        = string
}
variable "spoke1_vnet_name" {
  description = "The name of the spoke virtual network"
  default     = "spokeVnet"
  type        = string
}


variable "spoke1_address_space" {
  description = "Address space for the spoke virtual network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "spoke1_subnet_address_prefixes" {
  description = "Address prefixes for the spoke subnet"
  type        = list(string)
  default     = ["10.1.0.0/24"]
}

variable "spoke1_api_subnet_address_prefixes" {
  description = "Address prefixes for the spoke subnet"
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

// DNS Spoke variables
variable "dns_subscription_id" {
  description = "The subscription ID for the DNS spoke"
  type        = string

}
variable "dns_spoke_resource_group_name" {
  description = "The name of the spoke resource group"
  default     = "mydns_spokeResourceGroup"
  type        = string
}
variable "dns_spoke_vnet_name" {
  description = "The name of the spoke virtual network"
  default     = "spokeVnet"
  type        = string
}


variable "dns_spoke_address_space" {
  description = "Address space for the spoke virtual network"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "dns_spoke_inbound_subnet_address_prefixes" {
  description = "Address prefixes for the spoke subnet"
  type        = list(string)
  default     = ["10.2.0.0/24"]
}

# variable "dns_spoke_outbound_subnet_address_prefixes" {
#   description = "Address prefixes for the spoke subnet"
#   type        = list(string)
#   default     = ["10.2.1.0/24"]
# }

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default = {
    Owner = "Vineet"
  }
}