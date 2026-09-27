output "web_subnet_id" {
  value = data.azurerm_subnet.web.id
}

output "public_ip" {
  value = module.tacoweb.azurerm_public_ip_address
}