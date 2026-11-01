module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
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
  storage_account_name = "${var.storage_account_name_prefix}${random_string.unique_name.result}"
}

module "storage_account" {
  source                        = "Azure/avm-res-storage-storageaccount/azurerm"
  version                       = "0.6.0"
  location                      = var.location
  name                          = local.storage_account_name
  resource_group_name           = module.resource_group.name
  public_network_access_enabled = true
  network_rules                 = null
  tags                          = var.tags

  blob_properties = {
    versioning_enabled = true
  }

/*
Edit the main.tf file to add the following configuration for the storage account and containers.

In this lab, assume two different roles:

Network Engineer: Provisions Azure network-related resources and saves the remote state into the Azure Storage Account container called network.
SRE Team Engineer: Provisions Azure Kubernetes-related resources and saves the remote state into the Azure Storage Account container called application.
To meet these requirements, provision two blob containers in the storage account and grant the least priviledge permissions:
*/


  containers = {
    network = {
      name = "network"
      role_assignments = {
        blob_owner = {
          role_definition_id_or_name = "Storage Blob Data Contributor"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    },
    application = {
      name = "application"
      role_assignments = {
        blob_owner = {
          role_definition_id_or_name = "Storage Blob Data Contributor"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }
  }
}


/*
We will use the local provider to create the backend configuration files for the storage account and containers.

This is one of many ways to share this information with other teams. We are doing it locally in this lab, but in a real world scenario this information would be part of your CI / CD bootstrap.

In main.tf, add the following configuration
*/
resource "local_file" "backend_config" {
  for_each = {
    network     = "02-network"
    application = "03-application"
  }
  filename = "${path.module}/../${each.value}/config.azurerm.tfbackend"
  content  = <<-EOT
    storage_account_name = "${module.storage_account.name}"
    container_name       = "${each.key}"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  EOT
}


# We need to register the EncryptionAtHost feature for AKS to deploy successfully later in the lab.
# Required for AKS
resource "azapi_update_resource" "enable_encryption_at_host" {
  type = "Microsoft.Features/featureProviders/subscriptionFeatureRegistrations@2021-07-01"
  body = {
    properties = {}
  }
  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Features/featureProviders/Microsoft.Compute/subscriptionFeatureRegistrations/EncryptionAtHost"
}
