module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  name     = var.resource_group_name
  location = var.location
}

module "managed_identity" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.3"
  location            = var.location
  name                = var.user_assigned_managed_identity_name
  resource_group_name = module.resource_group.name
}

module "private_dns_zones" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  version             = "0.2.2"
  domain_name         = "privatelink.azurecr.io"
  resource_group_name = module.resource_group.name
}

data "azurerm_client_config" "current" {}

resource "random_string" "unique_name" {
  length  = 3
  special = false
  upper   = false
  lower   = true
  numeric = false
}

locals {
  container_registry_name = "${var.container_registry_name_prefix}${random_string.unique_name.result}"
}

data "azurerm_kubernetes_service_versions" "current" { location = var.location }

locals {
  kubernetes_version_split = split(".", data.azurerm_kubernetes_service_versions.current.latest_version)
  kubernetes_version       = join(".", [local.kubernetes_version_split[0], local.kubernetes_version_split[1]])
}

module "aks_cluster" {
  source  = "Azure/avm-ptn-aks-production/azurerm"
  version = "0.4.0"

  kubernetes_version  = local.kubernetes_version
  name                = var.aks_cluster_name
  resource_group_name = module.resource_group.name

  network = {
    name                = ""
    resource_group_name = ""
    node_subnet_id      = var.virtual_network_subnet_web_tier_id
    pod_cidr            = var.aks_cluster_pod_cidr
    #service_cidr        = var.aks_cluster_service_cidr
  }

  acr = {
    name                          = local.container_registry_name
    subnet_resource_id            = var.virtual_network_subnet_database_tier_id
    private_dns_zone_resource_ids = [module.private_dns_zones.resource_id]
  }

  managed_identities = {
    user_assigned_resource_ids = [
      module.managed_identity.resource_id
    ]
  }

  rbac_aad_tenant_id = data.azurerm_client_config.current.tenant_id

  location = var.location

  default_node_pool_vm_sku = "Standard_D2d_v5"
  
  node_pools = {
    workload = {
      name                 = "aksworkload"
      vm_size              = "Standard_D2d_v5"
      orchestrator_version = local.kubernetes_version
      max_count            = 10
      min_count            = 2
      os_sku               = "Ubuntu"
      mode                 = "User"
      os_disk_size_gb      = 128
    }
  }
}
