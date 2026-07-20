variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group where the network resources will be created."
}

variable "location" {
  type        = string
  description = "Azure region for the virtual network and subnets."
}

variable "vnet_name" {
  type        = string
  default     = "crescendo-vnet"
  description = "Name of the Azure virtual network."
}

variable "address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "Address space for the virtual network."
}

variable "public_subnet_name" {
  type        = string
  default     = "public-subnet"
  description = "Name of the public subnet for the web application VM."
}

variable "private_subnet_name" {
  type        = string
  default     = "private-subnet"
  description = "Name of the private subnet for internal resources."
}

variable "public_subnet_prefix" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Address prefix for the public subnet."
}

variable "private_subnet_prefix" {
  type        = string
  default     = "10.0.2.0/24"
  description = "Address prefix for the private subnet."
}

variable "application_gateway_subnet_name" {
  type        = string
  default     = "appgw-subnet"
  description = "Name of the subnet reserved for the Application Gateway."
}

variable "application_gateway_subnet_prefix" {
  type        = string
  default     = "10.0.3.0/24"
  description = "Address prefix for the Application Gateway subnet."
}

variable "bastion_subnet_name" {
  type        = string
  default     = "AzureBastionSubnet"
  description = "Name of the subnet reserved for Azure Bastion."
}

variable "bastion_subnet_prefix" {
  type        = string
  default     = "10.0.4.0/26"
  description = "Address prefix for the Azure Bastion subnet."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to network resources."
}
