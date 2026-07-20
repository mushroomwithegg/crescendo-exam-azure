output "vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "ID of the created virtual network."
}

output "public_subnet_id" {
  value       = azurerm_subnet.public.id
  description = "ID of the public subnet for web application hosting."
}

output "private_subnet_id" {
  value       = azurerm_subnet.private.id
  description = "ID of the private subnet."
}

output "application_gateway_subnet_id" {
  value       = azurerm_subnet.application_gateway.id
  description = "ID of the Application Gateway subnet."
}

output "public_subnet_name" {
  value       = azurerm_subnet.public.name
  description = "Name of the public subnet."
}

output "private_subnet_name" {
  value       = azurerm_subnet.private.name
  description = "Name of the private subnet."
}

output "nat_gateway_id" {
  value       = azurerm_nat_gateway.private.id
  description = "ID of the NAT gateway attached to the private subnet."
}

output "nat_gateway_public_ip_id" {
  value       = azurerm_public_ip.nat_gateway.id
  description = "ID of the public IP used by the NAT gateway."
}

output "public_route_table_id" {
  value       = azurerm_route_table.public.id
  description = "ID of the route table assigned to the public subnet."
}

output "bastion_subnet_id" {
  value       = azurerm_subnet.bastion.id
  description = "ID of the subnet reserved for Azure Bastion."
}
