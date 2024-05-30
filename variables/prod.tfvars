resource_group_name = "HubResourceGroup"
location            = "canadacentral"
hub_vnet_name       = "hubVnet"
firewall_name       = "myFirewall"
public_ip_name      = "myPublicIP"
tags = {
  "Owner"      = "Vineet1"
  "CostCenter" = "CC1"
}
spoke1_resource_group_name                = "Spoke1ResourceGroup"
spoke1_vnet_name                          = "spoke1Vnet"
spoke1_address_space                      = ["10.1.0.0/16"]
spoke1_subnet_address_prefixes            = ["10.1.0.0/24"]
dns_spoke_inbound_subnet_address_prefixes = ["10.1.1.0/24"]

# // Dns spoke variables
dns_subscription_id                       = "d41733f6-60ed-437f-bbb9-8bc2dc793277"
# dns_spoke_resource_group_name             = "dns_spoke_rg"
# dns_spoke_vnet_name                       = "dns_spoke_vnet"
# dns_spoke_address_space                   = ["10.2.0.0/16"]
# dns_spoke_inbound_subnet_address_prefixes = ["10.2.0.0/24"]
# # dns_spoke_outbound_subnet_address_prefixes = ["10.2.1.0/24"]
