resource_group_name = "crescendo-exam-rg"
location            = "westus2"
tags = {
  Environment = "dev"
}

vnet_name             = "crescendo-exam-vnet"
address_space         = ["10.0.0.0/16"]
public_subnet_name    = "crescendo-exam-public-subnet"
private_subnet_name   = "crescendo-exam-private-subnet"
public_subnet_prefix  = "10.0.1.0/24"
private_subnet_prefix = "10.0.2.0/24"

admin_username       = "azureuser"
admin_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9FwrxYcReGWP6ZA9sQV/oQK+9KfKvOBk9XhfyfRvbvFD7/xHsktReqWB31a1PHohlELhIM7agczAMBPUilza+SXAuZK6qF4WEaqqyu8vhIvsZc8VrctfGpGNKDx+Ocb9/3HGHCBaGRrWTrKJhfroJW7a2d5l2pxIBbscjPY/tmEmnUmkN0hieOgYb9vPO8qFxtl99dBGo3+ybSmCEAfNqHn6Ci/hYVeJD99pDW92F+db/rwb8039LvTQLl0R6n3oj7JQXCEOujPoj2YxuaIQGbh1oBe+gEd+RMwLpmlnP8ytnTPkjGW4M6KFPlKlbsbuABOfVZLxdNIGb3vdsoB6TmyANSLczfCP3glfuWnsPJ6V+skqmE6r2K05GgsPa7IOtu8oPv+b5J0YCgVLnfN72rT59dIQzYA0uNIP64g1bR9LMZDRloO+k0/4oJVfBKhFgXZXDswoYioZe9x+iy7XtRDitW7Waly1WXGesw1zJYRv+GdDm6H1FrPliIxEXQ5+ftsbMqRgTacuPJVRwvgKEgBksEFZ0YecP39v12c9Kc2INmMHHMh0G8k3sGPWiQS84qSAX+LM0w1e+jwOxXitl4ghJwnRmbSXY1Bg0MTZ67OzE18gjHil7GLH34byZth202Zj3ThIL3uJe1xUpkToq1QucDZ29Z+Y40EjFSZ/FdQ== rei.saga@outlook.com"
vm_name              = "magnolia-vm"
vm_size              = "Standard_D2s_v3"
vm_image_sku         = "20_04-lts-gen2"
allowed_ssh_cidr     = "122.2.109.10/32"