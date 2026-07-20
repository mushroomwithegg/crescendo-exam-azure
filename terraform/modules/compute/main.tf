resource "azurerm_network_security_group" "vm" {
  count               = var.allowed_ssh_cidr != "" || var.application_gateway_subnet_prefix != "" || var.bastion_subnet_prefix != "" ? 1 : 0
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.application_gateway_subnet_prefix != "" ? [1] : []
    content {
      name                       = "allow_appgw_http"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = var.application_gateway_subnet_prefix
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = var.bastion_subnet_prefix != "" ? [1] : []
    content {
      name                       = "allow_bastion_ssh"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = var.bastion_subnet_prefix
      destination_address_prefix = "*"
    }
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "vm_subnet" {
  count                     = var.allowed_ssh_cidr != "" || var.application_gateway_subnet_prefix != "" ? 1 : 0
  subnet_id                 = var.public_subnet_id
  network_security_group_id = azurerm_network_security_group.vm[0].id
}

resource "azurerm_linux_virtual_machine_scale_set" "vm" {
  name                = "${var.vm_name}-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones

  sku       = var.vm_size
  instances = 1

  upgrade_mode = "Manual"

  network_interface {
    name    = "primary"
    primary = true

    ip_configuration {
      name                                         = "ipconfig"
      subnet_id                                    = var.public_subnet_id
      primary                                      = true
      application_gateway_backend_address_pool_ids = [var.application_gateway_backend_pool_id]
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  custom_data = base64encode(trimspace(<<-EOT
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx openjdk-11-jdk unzip wget
echo 'JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"' | tee -a /etc/environment
systemctl enable nginx
systemctl start nginx
# Verify nginx is running before writing to webroot
sleep 2
if ! systemctl is-active --quiet nginx; then
  echo "[$(date)] ERROR: nginx failed to start"
  exit 1
fi

# Install Magnolia CMS (example application)
wget -O magnolia-cms.zip https://nexus.magnolia-cms.com/repository/public/info/magnolia/bundle/magnolia-community-demo-webapp/6.2.74/magnolia-community-demo-webapp-6.2.74-tomcat-bundle.zip
unzip magnolia-cms.zip
./$(find . -name magnolia_control.sh) start --ignore-open-files-limit

# Create nginx reverse proxy configuration for Magnolia CMS
echo "[$(date)] Creating nginx reverse proxy for Magnolia CMS..."
cat > /etc/nginx/conf.d/magnolia.conf <<'NGINX_CONF'
server {
  listen 80;
  server_name _;

  client_max_body_size 100M;

  location / {
    proxy_pass http://localhost:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # Fix potential redirect loops
    proxy_redirect off;
  }
}
NGINX_CONF

cp /etc/nginx/conf.d/magnolia.conf /etc/nginx/sites-available/magnolia
ln -s /etc/nginx/sites-available/magnolia /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Reload nginx to apply the new configuration
systemctl reload nginx

echo "[$(date)] User data script completed successfully"
EOT
  ))

  tags = var.tags
}

resource "azurerm_monitor_autoscale_setting" "vmss" {
  name                = "${var.vm_name}-autoscale"
  enabled             = true
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vm.id

  profile {
    name = "Auto scale based on Cpu and Memory"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vm.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 90
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Available Memory Percentage"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vm.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vm.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Available Memory Percentage"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vm.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
  }

  tags = var.tags
}
