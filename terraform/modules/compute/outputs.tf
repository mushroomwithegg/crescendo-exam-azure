output "vmss_id" {
  value       = azurerm_linux_virtual_machine_scale_set.vm.id
  description = "ID of the created virtual machine scale set."
}

output "vmss_name" {
  value       = azurerm_linux_virtual_machine_scale_set.vm.name
  description = "Name of the created virtual machine scale set."
}

output "magnolia_version" {
  value       = var.magnolia_version
  description = "Magnolia CMS version deployed to the VM scale set."
}
