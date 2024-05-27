resource "azurerm_virtual_network" "spoke_vnet" {
  name                = var.spoke_vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.spoke_address_space
}

resource "azurerm_subnet" "spoke_subnet" {
  name                 = "spoke1Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = var.spoke_subnet_address_prefixes
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = format("%sTo%s", azurerm_virtual_network.hub_vnet.name, azurerm_virtual_network.spoke_vnet.name)
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = format("%sTo%s", azurerm_virtual_network.spoke_vnet.name, azurerm_virtual_network.hub_vnet.name)
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_route_table" "rt" {
  name                = "myRouteTable"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name                   = "myRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "a" {
  subnet_id      = azurerm_subnet.spoke_subnet.id
  route_table_id = azurerm_route_table.rt.id
}