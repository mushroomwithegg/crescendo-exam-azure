terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.8"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

module "network" {
  source                            = "./modules/network"
  resource_group_name               = var.resource_group_name
  location                          = var.location
  vnet_name                         = var.vnet_name
  address_space                     = var.address_space
  public_subnet_name                = var.public_subnet_name
  private_subnet_name               = var.private_subnet_name
  public_subnet_prefix              = var.public_subnet_prefix
  private_subnet_prefix             = var.private_subnet_prefix
  application_gateway_subnet_name   = var.application_gateway_subnet_name
  application_gateway_subnet_prefix = var.application_gateway_subnet_prefix
  bastion_subnet_name               = var.bastion_subnet_name
  bastion_subnet_prefix             = var.bastion_subnet_prefix
  tags                              = var.tags
}

module "compute" {
  source                              = "./modules/compute"
  resource_group_name                 = var.resource_group_name
  location                            = var.location
  vm_name                             = var.vm_name
  vm_size                             = var.vm_size
  zones                               = var.zones
  admin_username                      = var.admin_username
  public_subnet_id                    = module.network.public_subnet_id
  admin_ssh_public_key                = var.admin_ssh_public_key
  vm_image_publisher                  = var.vm_image_publisher
  vm_image_offer                      = var.vm_image_offer
  vm_image_sku                        = var.vm_image_sku
  vm_image_version                    = var.vm_image_version
  magnolia_version                    = var.magnolia_version
  allowed_ssh_cidr                    = var.allowed_ssh_cidr
  application_gateway_subnet_prefix   = var.application_gateway_subnet_prefix
  bastion_subnet_prefix               = var.bastion_subnet_prefix
  instances                           = var.instances
  upgrade_mode                        = var.upgrade_mode
  rolling_upgrade_policy              = var.rolling_upgrade_policy
  application_gateway_backend_pool_id = tolist(azurerm_application_gateway.this.backend_address_pool)[0].id
  application_gateway_health_probe_id = tolist(azurerm_application_gateway.this.probe)[0].id
  tags                                = var.tags
}

resource "azurerm_public_ip" "application_gateway" {
  name                = "${var.vnet_name}-appgw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "bastion" {
  name                = "${var.vnet_name}-bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = "${var.vnet_name}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = module.network.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = "${var.vnet_name}-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = module.network.application_gateway_subnet_id
  }

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.application_gateway.id
  }

  backend_address_pool {
    name = "appgw-backend-pool"
  }

  backend_http_settings {
    name                  = "appgw-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "appgw-health-probe"
  }

  http_listener {
    name                           = "appgw-http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "appgw-routing-rule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "appgw-http-listener"
    backend_address_pool_name  = "appgw-backend-pool"
    backend_http_settings_name = "appgw-backend-http-settings"
  }

  probe {
    name                = "appgw-health-probe"
    protocol            = "Http"
    host                = "localhost"
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  tags = var.tags
}
