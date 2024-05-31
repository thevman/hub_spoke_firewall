resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "firewall_subnet" {
  # checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.firewall_subnet_address_prefixes
}

resource "azurerm_public_ip" "firewall_pip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "fw" {
  # checkov:skip=CKV_AZURE_216: "Ensure DenyIntelMode is set to Deny for Azure Firewalls"
  name                = var.firewall_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_tier            = "Standard"
  sku_name            = "AZFW_VNet"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }
  firewall_policy_id = azurerm_firewall_policy.policy.id
  tags               = var.tags
}

resource "azurerm_firewall_policy" "policy" {
  # checkov:skip=CKV_AZURE_220: "Ensure Firewall policy has IDPS mode as deny"

  name                = var.firewall_policy_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns {
    proxy_enabled = true
    servers       = [azurerm_private_dns_resolver_inbound_endpoint.example.ip_configurations[0].private_ip_address]
  }
  tags = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "example" {
  name               = "example-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 500
  application_rule_collection {
    name     = "app_rule_collection1"
    priority = 500
    action   = "Allow"
    rule {
      destination_fqdn_tags = ["AzureKubernetesService"]
      name                  = "VM-runner-api-fqdn"
      source_addresses      = var.spoke1_subnet_address_prefixes
      protocols {
        port = 443
        type = "Https"
      }
      protocols {
        port = 80
        type = "Http"
      }
    }
    rule {
      destination_fqdns = ["github.com", "api.github.com", "*.actions.githubusercontent.com", "codeload.github.com", "ghcr.io", "*.actions.githubusercontent.com", "results-receiver.actions.githubusercontent.com", "*.blob.core.windows.net", "objects.githubusercontent.com", "objects-origin.githubusercontent.com", "github-releases.githubusercontent.com", "github-registry-files.githubusercontent.com", "*.actions.githubusercontent.com", "*.pkg.github.com", "ghcr.io", "github-cloud.githubusercontent.com", "github-cloud.s3.amazonaws.com", "*.blobstorage.azure.net", "motd.ubuntu.com"]
      name              = "VM-runner-github-fqdn"
      source_addresses  = var.spoke1_subnet_address_prefixes
      protocols {
        port = 443
        type = "Https"
      }
      protocols {
        port = 80
        type = "Http"
      }
    }
  }

  network_rule_collection {
    name     = "aksfwnr"
    priority = 100
    action   = "Allow"
    rule {
      destination_addresses = ["AzureCloud.canadacentral"]
      destination_ports     = ["1194"]
      name                  = "VM-runner-apiudp"
      protocols             = ["UDP"]
      source_addresses      = var.spoke1_subnet_address_prefixes
    }
    rule {
      destination_addresses = ["AzureCloud.canadacentral"]
      destination_ports     = ["9000"]
      name                  = "VM-runner-apitcp"
      protocols             = ["TCP"]
      source_addresses      = var.spoke1_subnet_address_prefixes
    }
    rule {
      destination_fqdns = ["ntp.ubuntu.com"]
      destination_ports = ["123"]
      name              = "VM-runner-time"
      protocols         = ["UDP"]
      source_addresses  = var.spoke1_subnet_address_prefixes
    }
    rule {
      destination_fqdns = ["ghcr.io", "pkg-containers.githubusercontent.com"]
      destination_ports = ["443"]
      name              = "VM-runner-ghcr"
      protocols         = ["TCP"]
      source_addresses  = var.spoke1_subnet_address_prefixes
    }
    rule {
      destination_fqdns = ["docker.io", "registry-1.docker.io", "production.cloudflare.docker.com"]
      destination_ports = ["443"]
      name              = "VM-runner-docker"
      protocols         = ["TCP"]
      source_addresses  = var.spoke1_subnet_address_prefixes
    }
    rule {
      destination_fqdns = ["sms-runner-cluster-01-75pvierq.hcp.canadacentral.azmk8s.io"]
      destination_ports = ["443", "80"]
      name              = "VM-runner-apihttp"
      protocols         = ["TCP"]
      source_addresses  = var.spoke1_subnet_address_prefixes
    }
    rule {
      destination_addresses = ["*"]
      destination_ports     = ["53"]
      name                  = "VM-runner-dns"
      protocols             = ["TCP", "UDP"]
      source_addresses      = var.spoke1_subnet_address_prefixes
    }
  }
}