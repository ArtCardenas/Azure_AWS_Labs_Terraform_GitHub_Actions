variable "location" {
  type        = string
  default     = "swedencentral"
  description = "The region to deploy the resources to"
}

variable "resource_group_name" {
  type        = string
  default     = "rg-demo-dev-swedencentral-003"
  description = "The name of the resource group in which the resources will be deployed"
}

variable "aks_cluster_name" {
  type        = string
  default     = "demo-dev-swedencentral-001" # The upstream module will add "aks-" as prefix
  description = "The name to assign to the AKS Cluster"
}

variable "aks_cluster_pod_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "The CIDR range for the AKS Cluster pods"
}

variable "aks_cluster_service_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "The CIDR range for the AKS Cluster services"
}

variable "container_registry_name_prefix" {
  type        = string
  default     = "acrdemodevswe001"
  description = "The name to assign to the Azure Container Registry"
}

variable "user_assigned_managed_identity_name" {
  type        = string
  default     = "uami-demo-dev-swedencrental-001"
  description = "The name to assign to the User Assigned Identity that the AKS Cluster will use"
}

variable "virtual_network_subnet_web_tier_id" {
  type        = string
  description = "The ID of the subnet to which the AKS Cluster will be connected"
}

variable "virtual_network_subnet_database_tier_id" {
  type        = string
  description = "The ID of the subnet to which the Container Registry will be connected"
}
