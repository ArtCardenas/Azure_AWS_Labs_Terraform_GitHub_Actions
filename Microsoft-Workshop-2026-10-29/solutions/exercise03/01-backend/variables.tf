variable "location" {
  type        = string
  default     = "swedencentral"
  description = "The region to deploy the resources to"
}

variable "resource_group_name" {
  type        = string
  default     = "rg-demo-dev-swedencentral-001"
  description = "The name of the resource group for the Storage Account and App Configuration which will contain the terraform backend and exported values"
}

variable "storage_account_name_prefix" {
  type        = string
  default     = "stdemodevswe001"
  description = "The name of the storage account to use for the backend"
}

variable "tags" {
  type = map(string)
  default = {
    env  = "AVM Lab"
    dept = "Skillable"
  }
  description = "Tags to apply to the resources"
}
