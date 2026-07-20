output "network_public_subnet_id" {
  value       = module.network.public_subnet_id
  description = "ID of the public subnet created by the network module (for attaching VMs)."
}

output "network_vnet_id" {
  value       = module.network.vnet_id
  description = "ID of the virtual network created by the network module."
}

output "application_gateway_id" {
  value       = azurerm_application_gateway.this.id
  description = "ID of the created Application Gateway."
}

output "application_gateway_public_ip_id" {
  value       = azurerm_public_ip.application_gateway.id
  description = "ID of the public IP assigned to the Application Gateway."
}

output "application_gateway_public_ip_address" {
  value       = azurerm_public_ip.application_gateway.ip_address
  description = "Public IP address assigned to the Application Gateway."
}
