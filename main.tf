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
  address_prefixes     = ["10.0.1.0/24"]
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
  tags                = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "example" {
  name               = "example-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 500
  application_rule_collection {
    name     = "app_rule_collection1"
    priority = 500
    action   = "Deny"
    rule {
      destination_fqdns = ["*github.com", "*githubusercontent.com"]
      name              = "Allow-github"
      source_addresses  = var.spoke1_address_space
      protocols {
        port = 443
        type = "Https"
      }
    }
    rule {
      destination_fqdns = ["*.docker.com"]
      name              = "Allow-Docker"
      source_addresses  = var.spoke1_address_space
      protocols {
        port = 443
        type = "Https"
      }
    }
    rule {
      destination_fqdns = ["apt.releases.hashicorp.com", "releases.hashicorp.com", "registry.terraform.io", "pypi.org", "files.pythonhosted.org", "api0.prismacloud.io", "www.bridgecrew.cloud"]
      name              = "VM-runner-terraformdeployment"
      source_addresses  = var.spoke1_address_space
      protocols {
        port = 443
        type = "Https"
      }
    }
    rule {
      destination_fqdns = ["mcr.microsoft.com", "*.data.mcr.microsoft.com", "ghcr.io", "management.azure.com", "*.blob.core.windows.net", "k8s.gcr.io", "storage.googleapis.com", "registry.k8s.io", "*.docker.io", "kubernetes.github.io", "login.microsoftonline.com", "us-east4-docker.pkg.dev", "*.azureedge.net", "vault.azure.net", "acs-mirror.azureedge.net"]
      name              = "k8s-runner-cc-01-Https"
      source_addresses  = var.spoke1_address_space
      protocols {
        port = 443
        type = "Https"
      }
    }
  }

  network_rule_collection {
    name     = "network_rule_collection1"
    priority = 400
    action   = "Allow"
    rule {
      destination_fqdns = ["apt.releases.hashicorp.com", "releases.hashicorp.com", "github.com", "registry.terraform.io", "pypi.org"]
      destination_ports = ["22"]
      name              = "VM-runner-terraformdeployment01"
      protocols         = ["TCP"]
      source_addresses  = var.spoke1_subnet_address_prefixes
    }
    rule {
      destination_fqdns = ["production.cloudflare.docker.com"]
      destination_ports = ["*"]
      name              = "k8s-runner-cc-01-docker"
      protocols         = ["Any"]
      source_addresses  = var.spoke1_subnet_address_prefixes
    }
    rule {
      destination_addresses = ["VirtualNetwork"]
      destination_ports     = ["*"]
      name                  = "k8s-runner-cc-01-Any"
      protocols             = ["Any"]
      source_addresses      = ["*"]
    }
  }

  nat_rule_collection {
    name     = "nat_rule_collection1"
    priority = 300
    action   = "Dnat"
    rule {
      name                = "nat_rule_collection1_rule1"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["10.0.0.1", "10.0.0.2"]
      destination_address = "192.168.1.1"
      destination_ports   = ["80"]
      translated_address  = "192.168.0.1"
      translated_port     = "8080"
    }
  }
}