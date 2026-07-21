variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the virtual network and subnets will be created."
  default     = "crescendo-exam-rg"
}

variable "location" {
  type        = string
  description = "Azure region for the network deployment."
  default     = "eastus"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Azure virtual network."
  default     = "crescendo-vnet"
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the virtual network."
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_name" {
  type        = string
  description = "Name of the public subnet for the web application VM."
  default     = "public-subnet"
}

variable "private_subnet_name" {
  type        = string
  description = "Name of the private subnet for internal resources."
  default     = "private-subnet"
}

variable "public_subnet_prefix" {
  type        = string
  description = "Address prefix for the public subnet."
  default     = "10.0.1.0/24"
}

variable "private_subnet_prefix" {
  type        = string
  description = "Address prefix for the private subnet."
  default     = "10.0.2.0/24"
}

variable "application_gateway_subnet_name" {
  type        = string
  description = "Name of the subnet reserved for the Application Gateway."
  default     = "appgw-subnet"
}

variable "application_gateway_subnet_prefix" {
  type        = string
  description = "Address prefix for the Application Gateway subnet."
  default     = "10.0.3.0/24"
}

variable "bastion_subnet_name" {
  type        = string
  description = "Name of the subnet reserved for Azure Bastion."
  default     = "AzureBastionSubnet"
}

variable "bastion_subnet_prefix" {
  type        = string
  description = "Address prefix for the Azure Bastion subnet."
  default     = "10.0.4.0/26"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to created network resources."
  default = {
    Environment = "dev"
  }
}

variable "admin_ssh_public_key" {
  type        = string
  description = "Public SSH key for VM admin access (required for the compute module)."
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine."
  default     = "web-vm"
}

variable "vm_size" {
  type        = string
  description = "The size of the Virtual Machine Scale Set."
  default     = "D2ps_v6"
}

variable "instances" {
  type        = number
  description = "Number of instances for the compute VM scale set. Use more than 1 for rolling upgrades."
  default     = 1
}

variable "upgrade_mode" {
  type        = string
  description = "VM scale set upgrade mode (Manual, Automatic, Rolling)."
  default     = "Manual"
}

variable "rolling_upgrade_policy" {
  type = object({
    max_batch_instance_percent              = number
    max_unhealthy_instance_percent          = number
    max_unhealthy_upgraded_instance_percent = number
    pause_time_between_batches              = string
  })
  description = "Rolling upgrade policy values when upgrade_mode is Rolling."
  default = {
    max_batch_instance_percent              = 50
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT10M"
  }
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for the VM Scale Set."
  default     = ["1", "2"]
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM."
  default     = "azureuser"
}

variable "vm_image_publisher" {
  type        = string
  description = "Publisher of the VM image."
  default     = "Canonical"
}

variable "vm_image_offer" {
  type        = string
  description = "Offer of the VM image."
  default     = "0001-com-ubuntu-server-focal"
}

variable "vm_image_sku" {
  type        = string
  description = "SKU of the VM image."
  default     = "20_04-lts-gen2"
}

variable "vm_image_version" {
  type        = string
  description = "Version of the VM image."
  default     = "latest"
}

variable "magnolia_version" {
  type        = string
  description = "Magnolia CMS version to install on the compute VM."
  default     = "6.2.74"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR (e.g. 1.2.3.4/32) allowed to SSH into the VM. Set to empty string to disable NSG."
  default     = ""
}
