resource "azurerm_resource_group" "spoke1_rg" {
  name     = var.spoke1_resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "spoke_vnet" {
  # checkov:skip=CKV_AZURE_182: "Ensure that VNET has at least 2 connected DNS Endpoints"
  name                = var.spoke1_vnet_name
  location            = azurerm_resource_group.spoke1_rg.location
  resource_group_name = azurerm_resource_group.spoke1_rg.name
  address_space       = var.spoke1_address_space
  dns_servers         = [azurerm_private_dns_resolver_inbound_endpoint.example.ip_configurations[0].private_ip_address]
  tags                = var.tags
}

resource "azurerm_subnet" "spoke_subnet" {
  # checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  name                 = "spoke1Subnet"
  resource_group_name  = azurerm_resource_group.spoke1_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = var.spoke1_subnet_address_prefixes
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = format("%sTo%s", azurerm_virtual_network.hub_vnet.name, azurerm_virtual_network.spoke_vnet.name)
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = format("%sTo%s", azurerm_virtual_network.spoke_vnet.name, azurerm_virtual_network.hub_vnet.name)
  resource_group_name       = azurerm_resource_group.spoke1_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_route_table" "rt" {
  name                = "myRouteTable"
  location            = azurerm_resource_group.spoke1_rg.location
  resource_group_name = azurerm_resource_group.spoke1_rg.name

  route {
    name                   = "myRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
  route {
    name           = "fwip"
    address_prefix = "52.237.27.95/32"
    next_hop_type  = "Internet"
  }
  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "a" {
  subnet_id      = azurerm_subnet.spoke_subnet.id
  route_table_id = azurerm_route_table.rt.id
}