resource "azurerm_resource_group" "dns_spoke_rg" {
  name     = var.dns_spoke_resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "dns_spoke_vnet" {
  name                = var.dns_spoke_vnet_name
  location            = azurerm_resource_group.dns_spoke_rg.location
  resource_group_name = azurerm_resource_group.dns_spoke_rg.name
  address_space       = var.dns_spoke_address_space
}

resource "azurerm_subnet" "dns_spoke_inbound_subnet" {
  # checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  name                 = "InboundSubnet"
  resource_group_name  = azurerm_resource_group.dns_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.dns_spoke_vnet.name
  address_prefixes     = var.dns_spoke_inbound_subnet_address_prefixes
}

resource "azurerm_subnet" "dns_spoke_outbound_subnet" {
  # checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  name                 = "OutboundSubnet"
  resource_group_name  = azurerm_resource_group.dns_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.dns_spoke_vnet.name
  address_prefixes     = var.dns_spoke_outbound_subnet_address_prefixes
}

resource "azurerm_virtual_network_peering" "hub_to_dns_spoke" {
  name                      = format("%sTo%s", azurerm_virtual_network.hub_vnet.name, azurerm_virtual_network.dns_spoke_vnet.name)
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.dns_spoke_vnet.id
}

resource "azurerm_virtual_network_peering" "dns_spoke_to_hub" {
  name                      = format("%sTo%s", azurerm_virtual_network.dns_spoke_vnet.name, azurerm_virtual_network.hub_vnet.name)
  resource_group_name       = azurerm_resource_group.dns_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.dns_spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_route_table" "dns_spoke_rt" {
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
  subnet_id      = azurerm_subnet.dns_spoke_inbound_subnet.id
  route_table_id = azurerm_route_table.dns_spoke_rt.id
}


resource "azurerm_subnet_route_table_association" "dns_spoke_rt_outbound_association" {
  subnet_id      = azurerm_subnet.dns_spoke_outbound_subnet.id
  route_table_id = azurerm_route_table.dns_spoke_rt.id
}