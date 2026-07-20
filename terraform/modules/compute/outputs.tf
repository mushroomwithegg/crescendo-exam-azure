output "vmss_id" {
  value       = azurerm_linux_virtual_machine_scale_set.vm.id
  description = "ID of the created virtual machine scale set."
}

output "vmss_name" {
  value       = azurerm_linux_virtual_machine_scale_set.vm.name
  description = "Name of the created virtual machine scale set."
}
