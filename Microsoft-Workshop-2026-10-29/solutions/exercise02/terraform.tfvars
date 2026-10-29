location                      = "swedencentral"
resource_group_name           = "rg-demo-dev-swedencentral-001"
virtual_network_name          = "vnet-demo-dev-swedencentral-001"
virtual_network_subnet_name   = "subnet-demo"
virtual_network_address_space = "10.0.0.0/16"
#virtual_network_subnet_prefix = "10.0.0.0/24"
storage_account_name_prefix = "stodemodevswe001"
tags = {
  environment = "lab"
  owner       = "demo@madeup.net"
}
log_analytics_workspace_name = "law-demo-dev-swedencentral-001"
