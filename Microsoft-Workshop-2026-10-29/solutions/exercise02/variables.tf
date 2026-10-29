variable "location" {
  type        = string
  description = "Azure region where resources will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that contains the resources."
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the virtual network to create or reference."
}

variable "virtual_network_subnet_name" {
  type        = string
  description = "Name of the subnet within the virtual network for IP allocations."
}

variable "virtual_network_address_space" {
  type        = string
  description = "CIDR address space assigned to the virtual network."
}

/* variable "virtual_network_subnet_prefix" {  
  type = string
} */

variable "storage_account_name_prefix" {
  type        = string
  description = "Prefix used when constructing globally unique storage account names."
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to all created resources."
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of the Log Analytics workspace used for diagnostics."
}
