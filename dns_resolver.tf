resource "azurerm_resource_group" "dns_spoke_rg" {
  provider = azurerm.dns_spoke
  name     = var.dns_spoke_resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "dns_spoke_vnet" {
  provider            = azurerm.dns_spoke
  name                = var.dns_spoke_vnet_name
  location            = azurerm_resource_group.dns_spoke_rg.location
  resource_group_name = azurerm_resource_group.dns_spoke_rg.name
  address_space       = var.dns_spoke_address_space
}

resource "azurerm_subnet" "dns_spoke_inbound_subnet" {
  # checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  provider             = azurerm.dns_spoke
  name                 = "InboundSubnet"
  resource_group_name  = azurerm_resource_group.dns_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.dns_spoke_vnet.name
  address_prefixes     = var.dns_spoke_inbound_subnet_address_prefixes
  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

# resource "azurerm_subnet" "dns_spoke_outbound_subnet" {
#   # checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
#   name                 = "OutboundSubnet"
#   resource_group_name  = azurerm_resource_group.dns_spoke_rg.name
#   virtual_network_name = azurerm_virtual_network.dns_spoke_vnet.name
#   address_prefixes     = var.dns_spoke_outbound_subnet_address_prefixes
# }

resource "azurerm_virtual_network_peering" "hub_to_dns_spoke" {
  provider                  = azurerm.dns_spoke
  name                      = format("%sTo%s", azurerm_virtual_network.hub_vnet.name, azurerm_virtual_network.dns_spoke_vnet.name)
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.dns_spoke_vnet.id
}

resource "azurerm_virtual_network_peering" "dns_spoke_to_hub" {
  provider                  = azurerm.dns_spoke
  name                      = format("%sTo%s", azurerm_virtual_network.dns_spoke_vnet.name, azurerm_virtual_network.hub_vnet.name)
  resource_group_name       = azurerm_resource_group.dns_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.dns_spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_route_table" "dns_spoke_rt" {
  provider            = azurerm.dns_spoke
  name                = "myRouteTable"
  location            = azurerm_resource_group.dns_spoke_rg.location
  resource_group_name = azurerm_resource_group.dns_spoke_rg.name

  route {
    name                   = "myRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "dns_spoke_rt_inbound_association" {
  provider       = azurerm.dns_spoke
  subnet_id      = azurerm_subnet.dns_spoke_inbound_subnet.id
  route_table_id = azurerm_route_table.dns_spoke_rt.id
}


# resource "azurerm_subnet_route_table_association" "dns_spoke_rt_outbound_association" {
#   subnet_id      = azurerm_subnet.dns_spoke_outbound_subnet.id
#   route_table_id = azurerm_route_table.dns_spoke_rt.id
# }

resource "azurerm_private_dns_resolver" "test" {
  provider            = azurerm.dns_spoke
  name                = "example"
  resource_group_name = azurerm_resource_group.dns_spoke_rg.name
  location            = azurerm_resource_group.dns_spoke_rg.location
  virtual_network_id  = azurerm_virtual_network.dns_spoke_vnet.id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "example" {
  provider                = azurerm.dns_spoke
  name                    = "example-drie"
  private_dns_resolver_id = azurerm_private_dns_resolver.test.id
  location                = azurerm_private_dns_resolver.test.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.dns_spoke_inbound_subnet.id
  }
}

resource "azurerm_private_dns_zone" "example" {
  provider            = azurerm.dns_spoke
  name                = "canadacentral.privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.dns_spoke_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  provider              = azurerm.dns_spoke
  name                  = "test"
  resource_group_name   = azurerm_resource_group.dns_spoke_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.dns_spoke_vnet.id
}
