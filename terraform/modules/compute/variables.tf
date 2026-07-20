variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where compute resources will be created."
}

variable "location" {
  type        = string
  description = "Azure region for the compute resources."
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine."
  default     = "web-vm"
}

variable "vm_size" {
  type        = string
  description = "The size of the Virtual Machine."
  default     = "Standard_B1ms"
}

variable "instances" {
  type        = number
  description = "Number of VM instances in the scale set. Use more than 1 for rolling updates."
  default     = 1
}

variable "upgrade_mode" {
  type        = string
  description = "Upgrade mode for the VM Scale Set (Manual, Automatic, Rolling)."
  default     = "Manual"
}

variable "rolling_upgrade_policy" {
  type = object({
    max_batch_instance_percent             = number
    max_unhealthy_instance_percent         = number
    max_unhealthy_upgraded_instance_percent = number
    pause_time_between_batches             = string
  })
  description = "Rolling upgrade policy for the VMSS when upgrade_mode is Rolling."
  default = {
    max_batch_instance_percent             = 50
    max_unhealthy_instance_percent         = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches             = "PT5M"
  }
}

variable "public_subnet_id" {
  type        = string
  description = "ID of the public subnet where the VMSS instances will be placed."
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for the VM Scale Set."
  default     = []
}

variable "application_gateway_backend_pool_id" {
  type        = string
  description = "ID of the Application Gateway backend pool for the VM Scale Set."
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM."
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "Public SSH key for the admin user (no default; required)."
}

variable "application_gateway_subnet_prefix" {
  type        = string
  description = "The subnet prefix of the Application Gateway, used to allow backend HTTP traffic to the VM when an NSG is attached."
  default     = ""
}

variable "bastion_subnet_prefix" {
  type        = string
  description = "The subnet prefix of the Azure Bastion subnet, used to allow Bastion SSH traffic when an NSG is attached."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to compute resources."
  default     = {}
}

variable "vm_image_publisher" {
  type    = string
  default = "Canonical"
}

variable "vm_image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-focal"
}

variable "vm_image_sku" {
  type    = string
  default = "20_04-lts-gen2"
}

variable "vm_image_version" {
  type    = string
  default = "latest"
}

variable "magnolia_version" {
  type        = string
  description = "Magnolia CMS version to install in the compute module."
  default     = "6.2.74"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR (e.g. 1.2.3.4/32) allowed to SSH into the VM. Empty disables NSG creation."
  default     = ""
}
