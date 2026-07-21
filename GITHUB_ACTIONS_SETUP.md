# GitHub Actions Terraform Setup Guide

## Overview
This workflow automates Terraform plan and apply to Azure when code is pushed to the `main` branch.

## Prerequisites

1. **Azure Service Principal** - Create one using the Azure CLI:
   ```bash
   az ad sp create-for-rbac --name "terraform-sp" --role "Contributor" --scopes "/subscriptions/{SUBSCRIPTION_ID}"
   ```

2. **Terraform Backend Storage Account** - Already created per your local setup

## GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

1. Go to **Settings → Secrets and variables → Actions**
2. Add these secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AZURE_CLIENT_ID` | Service Principal App ID | From the `appId` field of the service principal |
| `AZURE_CLIENT_SECRET` | Service Principal password | From the `password` field |
| `AZURE_SUBSCRIPTION_ID` | Your Azure Subscription ID | Found in Azure Portal |
| `AZURE_TENANT_ID` | Azure Tenant ID | From the `tenant` field of the service principal |
| `ARM_BACKEND_RESOURCE_GROUP` | Resource Group name | Where your storage account exists |
| `ARM_BACKEND_STORAGE_ACCOUNT` | Storage account name | For Terraform state |
| `ARM_BACKEND_CONTAINER` | Container name | `tfstate` (from your setup) |
| `ARM_BACKEND_KEY` | State file name | e.g., `terraform.tfstate` |

## Example Service Principal Creation

```bash
# Create service principal
az ad sp create-for-rbac --name "terraform-github-sp" --role "Contributor"

# Output will look like:
# {
#   "appId": "AZURE_CLIENT_ID",
#   "displayName": "terraform-github-sp",
#   "password": "AZURE_CLIENT_SECRET",
#   "tenant": "AZURE_TENANT_ID"
# }
```

## Workflow Behavior

### On Pull Request:
- ✅ Runs `terraform plan`
- ✅ Validates terraform format & syntax
- ✅ Comments the plan on the PR
- ❌ Does NOT apply changes

### On Push to Main:
- ✅ Runs `terraform plan`
- ✅ Runs `terraform apply` automatically
- ✅ Displays outputs

### Manual Destroy via Workflow Dispatch
- ✅ Run the workflow manually from GitHub Actions
- ✅ Set `destroy=true` and `confirm_destroy=true` to execute `terraform destroy`
- ✅ Prevents accidental destroy from push or PR events

## Alternative: Using Azure Workload Identity Federation (Recommended for Enhanced Security)

Instead of storing credentials as secrets, you can use OIDC:

```bash
# Set up Workload Identity Federation
az identity create --name "github-terraform-id" --resource-group {RG_NAME}

# Create federated credential
az identity federated-credential create \
  --name "github-repo" \
  --identity-name "github-terraform-id" \
  --resource-group {RG_NAME} \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:{OWNER}/{REPO}:ref:refs/heads/main"
```

Then update the workflow to use OIDC (see `.github/workflows/terraform-oidc.yml`).

## Troubleshooting

### "Backend initialization failed"
- Verify the storage account name and container exist
- Check service principal has Storage Blob Data Contributor role
- Wait 5 minutes after role assignment for permissions to propagate

### "Terraform plan shows unexpected changes"
- Ensure local and remote state are in sync
- Run `terraform state list` to verify state
- Check variable defaults match your expectations

### "Apply failed due to insufficient permissions"
- Verify service principal has Contributor role on the subscription
- Check the specific resource error in the workflow logs

## Local Development Workflow

```bash
# Initialize with local backend
terraform init -backend-config="creds.tfvars"

# Plan changes
terraform plan -out=tfplan

# Apply when satisfied
terraform apply tfplan
```

## Next Steps

1. Create a GitHub repository and push this code
2. Configure the secrets in GitHub Settings
3. Create a test PR to verify the plan workflow
4. Merge to main to trigger the apply workflow
