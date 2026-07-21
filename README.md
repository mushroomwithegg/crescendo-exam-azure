# Procedure

## Making Azure Storage Account as your Terraform Backend
1. Create a `Storage Account` in azure.
2. Inside the generated `Storage Account`, create a container named `tfstate`.
3. To access proceed with either Local Setup or GitHub Account Setup.

### Local Setup
1. Using `az login`, login in Azure Portal using the account that has access to *Step 1*.
2. In the created `Storage Account`, go to `Access Control (IAM)` and add a new role assignment and add a new role called **Storage Blob Data Contributor** & **Contributor** under the account that was used in `az login`.
3. Wait around 3-5mins for the access to refresh and then run `terraform init -backend-config="creds.tfvars"`.

## Azure Architecture Diagram

The following diagram is generated from the Terraform configuration in [terraform/](terraform/) and values in [terraform/terraform.tfvars](terraform/terraform.tfvars).

```mermaid
flowchart TB
    Internet((Internet))
    Operator((Admin Operator))

    subgraph "Resource Group: crescendo-exam-rg"
        subgraph "VNet: crescendo-exam-vnet 10.0.0.0/16"
            subgraph "App Gateway Subnet 10.0.3.0/24"
                APPGW["Application Gateway<br/>Standard_v2<br/>Public Listener:80"]
            end

            subgraph "Public Subnet 10.0.1.0/24"
                VMSS["Linux VM Scale Set<br/>magnolia-vm-vmss<br/>2 instances<br/>SKU: Standard_D2s_v3"]
                NSG["Network Security Group<br/>magnolia-vm-nsg"]
                RT_PUBLIC["Route Table<br/>0.0.0.0/0 -> Internet"]
            end

            subgraph "Private Subnet 10.0.2.0/24"
                NAT["NAT Gateway<br/>Standard"]
            end

            subgraph "AzureBastionSubnet 10.0.4.0/26"
                BASTION["Azure Bastion"]
            end

            PIP_APPGW["Public IP<br/>for Application Gateway"]
            PIP_BASTION["Public IP<br/>for Bastion"]
            PIP_NAT["Public IP<br/>for NAT Gateway"]
            AS["Autoscale Setting<br/>CPU/Memory rules"]
        end
    end

    Internet --> PIP_APPGW --> APPGW
    APPGW -->|HTTP 80| VMSS

    Operator --> PIP_BASTION --> BASTION -->|SSH 22| VMSS

    VMSS --> AS
    VMSS --> NSG
    VMSS --> RT_PUBLIC --> Internet
    NAT --> PIP_NAT --> Internet
```

