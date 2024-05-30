resource "azurerm_subnet" "dns_spoke_subnet" {
  # checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  name                 = "dnsSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "dns_spoke_inbound_subnet" {
  # checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  ##provider             = azurerm.dns_spoke
  name                 = "InboundSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.dns_spoke_inbound_subnet_address_prefixes
  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

resource "azurerm_private_dns_resolver" "test" {
  #provider            = azurerm.dns_spoke
  name                = "example"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  virtual_network_id  = azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "example" {
  #provider                = azurerm.dns_spoke
  name                    = "example-drie"
  private_dns_resolver_id = azurerm_private_dns_resolver.test.id
  location                = azurerm_private_dns_resolver.test.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.dns_spoke_inbound_subnet.id
  }
  # ip_configurations {
  #   private_ip_allocation_method = "Dynamic"
  #   subnet_id                    = azurerm_subnet.dns_spoke_inbound_subnet.id
  # }
}

# resource "azurerm_private_dns_zone" "example" {
#   #provider            = azurerm.dns_spoke
#   name                = "privatelink.canadacentral.azmk8s.io"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "example" {
#   #provider              = azurerm.dns_spoke
#   name                  = "test"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.example.name
#   virtual_network_id    = azurerm_virtual_network.hub_vnet.id
# }
