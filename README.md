# Terraform Microsoft Graph Entra Cloud Sync Configuration

This Terraform module automates the setup and configuration of Microsoft Entra Cloud Sync (formerly Azure AD Connect Cloud Sync) to synchronize on-premises Active Directory users, groups, and other objects to Microsoft Entra ID (Azure AD).

## Overview

This module performs the following operations:

1. **Enables on-premises synchronization** on the Microsoft Entra tenant
2. **Creates an Entra Cloud Sync application** from the Microsoft template
3. **Configures synchronization secrets** (domain and app key configuration)
4. **Creates and configures synchronization jobs** for:
   - Standard AD to Entra ID provisioning 
   - Password hash synchronization
5. **Applies custom schema configuration** for attribute mapping
6. **Starts the synchronization jobs** automatically

## Features

- ✅ Automated Entra Cloud Sync application deployment
- ✅ Custom synchronization schema support via template files
- ✅ Password hash synchronization configuration
- ✅ Multi-job synchronization setup (provisioning + password sync)
- ✅ Tenant-level sync enablement
- ✅ Schema customization through JSON templates

## Prerequisites

- **Microsoft Graph provider** >= 0.0.2
- **AzureAD provider** >= 3.0.0
- **Global Administrator** or **Hybrid Identity Administrator** permissions in Microsoft Entra ID
- **Enterprise Administrator** permissions in on-premises Active Directory
- Access to the target **Microsoft Entra tenant**

## Required Providers

```hcl
terraform {
  required_providers {
    msgraph = {
      source  = "microsoft/msgraph"
      version = ">= 0.0.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.0"
    }
  }
}
```

## Usage

### Basic Example

```hcl
module "entra_cloud_sync" {
  source = "./terraform-msgraph-entra-cloud-sync-config"
  
  ad_domain  = "contoso.com"
  tenant_id  = "12345678-1234-1234-1234-123456789012"
}
```

### Complete Example with Provider Configuration

```hcl
terraform {
  required_providers {
    msgraph = {
      source  = "microsoft/msgraph"
      version = ">= 0.0.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.0"
    }
  }
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "msgraph" {
  tenant_id = var.tenant_id
}

module "entra_cloud_sync" {
  source = "./terraform-msgraph-entra-cloud-sync-config"
  
  ad_domain  = "contoso.com"
  tenant_id  = "12345678-1234-1234-1234-123456789012"
}
```

## Input Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `ad_domain` | The on-premises Active Directory domain name (e.g., contoso.com) | `string` | ✅ | - |
| `tenant_id` | The Entra tenant ID where the Entra Cloud Sync application will be created | `string` | ✅ | - |

## Outputs

This module creates several resources but does not expose outputs by default. The following resources are created:

- **Service Principal**: For the Entra Cloud Sync application
- **Synchronization Jobs**: Two jobs (provisioning and password hash sync)
- **Synchronization Secrets**: Domain and application key configuration
- **Schema Configuration**: Custom attribute mapping rules

## File Structure

```
├── main.tf                           # Main resource definitions
├── variables.tf                      # Input variable declarations
├── providers.tf                      # Provider requirements
├── terraform.tfvars                  # Variable values (not included in repo)
├── jobschemas/
│   └── jobschema.json.tftpl         # Synchronization schema template
├── README.md                         # This file
└── LICENSE                          # License file
```

## Schema Customization

The module uses a customizable JSON template file (`jobschemas/jobschema.json.tftpl`) to define the synchronization schema. This file contains:

- **Object mappings** between AD and Entra ID
- **Attribute flow rules** for user and group properties
- **Transformation logic** for data conversion
- **Filter configurations** for object selection

To customize the schema:

1. Modify the `jobschemas/jobschema.json.tftpl` file
2. Update attribute mappings as needed
3. Run `terraform plan` and `terraform apply`

## Authentication

This module requires authentication to both Microsoft Graph and Azure AD. Configure authentication using one of these methods:

### Service Principal (Recommended for automation)

```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
```

### Azure CLI (For interactive use)

```bash
az login
az account set --subscription "your-subscription-id"
```

## Important Notes

⚠️ **Warning**: This module will:
- Enable on-premises synchronization on your tenant
- Create synchronization jobs that will start automatically
- Begin syncing users and groups from your on-premises AD

🔒 **Security**: Ensure proper access controls and review the synchronization schema before deployment.

📝 **Planning**: Test in a non-production environment first and review all attribute mappings.

## Common Issues

### Authentication Errors
- Ensure the service principal has sufficient permissions
- Verify tenant ID is correct
- Check that the providers are properly configured

### Synchronization Failures
- Verify the AD domain is accessible
- Check DNS resolution for the domain
- Ensure proper network connectivity

### Schema Validation
- Validate the JSON template syntax
- Ensure all required attributes are mapped
- Check for circular references in object mappings

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly in a non-production environment
5. Submit a pull request

## References

- [Microsoft Entra Cloud Sync Documentation](https://docs.microsoft.com/en-us/azure/active-directory/cloud-sync/)
- [Microsoft Graph API Reference](https://docs.microsoft.com/en-us/graph/api/overview)
- [Terraform Microsoft Graph Provider](https://registry.terraform.io/providers/microsoft/msgraph/latest/docs)

## Support

For issues related to:
- **This Terraform module**: Open an issue in this repository
- **Microsoft Entra Cloud Sync**: Contact Microsoft Support
- **Terraform providers**: Check the respective provider documentation

---

**Note**: This is an unofficial Terraform module. Use at your own risk and always test in non-production environments first.