module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.12.0"

  address_space       = [var.virtual_network_address_space]
  location            = var.location
  parent_id           = module.resource_group.resource_id
  enable_telemetry    = true
  name                = var.virtual_network_name
  tags                = var.tags
  diagnostic_settings = local.diagnostic_settings
}

module "ip_addresses" {
  source  = "Azure/avm-utl-network-ip-addresses/azurerm"
  version = "0.1.0"

  address_space = var.virtual_network_address_space
  address_prefixes = {
    demo = 24
  }
}

module "virtual_network_subnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "0.12.0"

  name             = var.virtual_network_subnet_name
  parent_id        = module.virtual_network.resource_id
  address_prefixes = [module.ip_addresses.address_prefixes["demo"]]
}

module "private_dns_zone" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.4.0"

  domain_name = "privatelink.blob.core.windows.net"
  parent_id   = module.resource_group.resource_id
  virtual_network_links = {
    vnetlink1 = {
      name   = "storage-account"
      vnetid = module.virtual_network.resource_id
    }
  }
  tags = var.tags
}

resource "random_string" "storage_account_name" {
  length  = 3
  upper   = false
  special = false
}

locals {
  storage_account_name = "${var.storage_account_name_prefix}${random_string.storage_account_name.result}"
}

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.3"

  location            = var.location
  name                = local.storage_account_name
  resource_group_name = module.resource_group.name
  containers = {
    demo = {
      name = "demo"
      tags = var.tags
    }
  }
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [module.private_dns_zone.resource_id]
      subnet_resource_id            = module.virtual_network_subnet.resource_id
      subresource_name              = "blob"
      tags                          = var.tags
    }
  }
  tags                                = var.tags
  diagnostic_settings_storage_account = local.diagnostic_settings
  diagnostic_settings_blob            = local.diagnostic_settings
}

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.4.2"

  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
  diagnostic_settings = local.diagnostic_settings
}

locals {
  diagnostic_settings = {
    sendToLogAnalytics = {
      name                  = "sendToLogAnalytics"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
}
