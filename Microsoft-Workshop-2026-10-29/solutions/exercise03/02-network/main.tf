module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_client_config" "data" {}

module "ip_addresses" {
  source           = "Azure/avm-utl-network-ip-addresses/azurerm"
  version          = "0.1.0"
  address_space    = var.virtual_network_address_space
  address_prefixes = { for key, value in var.virtual_network_subnets : key => value.address_prefix_size }
}

locals {
  subnets = { for key, value in var.virtual_network_subnets : key => {
    name             = value.name
    address_prefixes = [module.ip_addresses.address_prefixes[key]]
    network_security_group = {
      id = module.network_security_group[key].resource_id
    }
  } }
}

module "virtual_network" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  address_space       = [var.virtual_network_address_space]
  location            = var.location
  name                = var.virtual_network_name
  resource_group_name = module.resource_group.name
  subnets             = local.subnets
}

module "network_security_group" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  for_each            = var.virtual_network_subnets
  name                = each.value.network_security_group_name
  resource_group_name = module.resource_group.name
  location            = var.location
  security_rules      = var.network_security_group_default_rules
}

resource "local_file" "tfvars" {
  filename = "${path.module}/../03-application/terraform.tfvars"
  content  = <<-EOT
    virtual_network_id                      = "${module.virtual_network.resource_id}"
    virtual_network_subnet_web_tier_id      = "${module.virtual_network.subnets["web_tier"].resource_id}"
    virtual_network_subnet_database_tier_id = "${module.virtual_network.subnets["database_tier"].resource_id}"
  EOT
}
