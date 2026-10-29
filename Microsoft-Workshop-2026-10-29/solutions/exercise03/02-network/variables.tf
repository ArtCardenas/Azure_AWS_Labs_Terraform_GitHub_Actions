variable "location" {
  type        = string
  default     = "swedencentral"
  description = "The region to deploy the resources to"
}

variable "resource_group_name" {
  type        = string
  default     = "rg-demo-dev-swedencentral-002"
  description = "The name of the resource group in which the resources will be deployed"
}

variable "virtual_network_name" {
  type        = string
  default     = "vnet-demo-dev-swedencentral-001"
  description = "The name of the virtual network to be created"
}

variable "virtual_network_address_space" {
  type        = string
  default     = "10.10.0.0/22"
  description = "The address space for the virtual network"
}

variable "virtual_network_subnets" {
  type = map(object({
    name                        = string
    address_prefix_size         = number
    network_security_group_name = string
  }))
  default = {
    web_tier = {
      name                        = "subnet-web"
      address_prefix_size         = 24
      network_security_group_name = "nsg-demo-dev-swedencentral-001"
    }
    app_tier = {
      name                        = "subnet-app"
      address_prefix_size         = 24
      network_security_group_name = "nsg-demo-dev-swedencentral-002"
    }
    database_tier = {
      name                        = "subnet-database"
      address_prefix_size         = 27
      network_security_group_name = "nsg-demo-dev-swedencentral-003"
    }
  }
  description = "A map of subnets to be created within the virtual network"
}

variable "network_security_group_default_rules" {
  type = map(object({
    name                       = string
    access                     = string
    destination_address_prefix = string
    destination_port_ranges    = list(string)
    direction                  = string
    priority                   = number
    protocol                   = string
    source_address_prefix      = string
    source_port_range          = string
  }))
  default = {
    allow_http_https = {
      name                       = "allow-http-https"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["80", "443"]
      direction                  = "Inbound"
      priority                   = 200
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
  description = "A map of default rules for the network security group"
}
