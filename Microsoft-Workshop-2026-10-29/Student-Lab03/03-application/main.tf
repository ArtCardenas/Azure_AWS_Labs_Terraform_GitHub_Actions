# Create a new file main.tf and then add the resource group for the AKS cluster:
module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  name     = var.resource_group_name
  location = var.location
}

# Azure Kubernetes Service (AKS) clusters require a Microsoft Entra identity to access Azure resources like load balancers and managed disks. 
# Managed identities for Azure resources are the recommended way to authorize access from an AKS cluster to other Azure services. 
# Add the user assigned managed identity module to main.tf:
module "managed_identity" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.3"
  location            = var.location
  name                = var.user_assigned_managed_identity_name
  resource_group_name = module.resource_group.name
}

# Edit main.tf and add the private DNS zone module:
# You can limit access to a registry by assigning virtual network private IP addresses to the registry endpoints
# and using Azure Private Link. Network traffic between the clients on the virtual network and the registry's private endpoints 
# traverses the virtual network and a private link on the Microsoft backbone network, eliminating exposure from the public internet.
# https://learn.microsoft.com/en-us/azure/container-registry/container-registry-private-link 
module "private_dns_zones" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  version             = "0.2.2"
  domain_name         = "privatelink.azurecr.io"
  resource_group_name = module.resource_group.name
}

# Edit main.tf and add the AKS module:

# Azure Kubernetes Service (AKS) is a managed Kubernetes service that you can use to deploy and manage containerized applications. 
# You need minimal container orchestration expertise to use AKS. 
# AKS reduces the complexity and operational overhead of managing Kubernetes by offloading much of that responsibility to Azure. 
# AKS is an ideal platform for deploying and managing containerized applications that require high availability, scalability, 
# and portability, and for deploying applications to multiple regions, using open-source tools, and integrating with existing DevOps tools.

# Using Azure Verified Modules we are going to provision AKS cluster with the following configuration
# * AKS cluster min of 2 nodes and max of 10 nodes
# * Deploy on existing VNET
# * Nodes will be deployed on subnet_webtier_id subnet
# * Private Endpoints IPs issued from subnet_dbtier_id subnet
# * Utilize managed identity to manage cluster
# * Provision container registry

data "azurerm_client_config" "current" {}

resource "random_string" "unique_name" {
  length  = 3
  special = false
  upper   = false
  lower   = true
  numeric = false
}

locals {
  container_registry_name  = "${var.container_registry_name_prefix}${random_string.unique_name.result}"
}

data "azurerm_kubernetes_service_versions" "current" {  location = var.location}

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