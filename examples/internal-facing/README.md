# Internal-Facing Web App Deployment Example

This example demonstrates deploying an Azure Linux Web App with **private endpoint** and **public access disabled** for internal-only applications.

## Features

- ✅ **Public network access DISABLED** - No internet-facing access
- ✅ **Private Endpoint** - Secure internal connectivity via Azure Private Link
- ✅ **Private DNS Integration** - Automatic DNS registration for seamless name resolution
- ✅ **Premium SKU** - P1v3 or higher required for private endpoints
- ✅ **ALZ Compliant** - Full compliance with Azure Landing Zone policies
- ✅ **Enhanced Security** - Managed identity and diagnostic logging

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Corporate VNet                            │
│                                                               │
│  ┌──────────────────┐        ┌─────────────────────────┐   │
│  │   App Subnet     │        │  Private Endpoint        │   │
│  │                  │───────▶│  (Private IP: 10.0.1.10) │   │
│  │  Internal Users  │        │                          │   │
│  │  & Services      │        │  ┌────────────────────┐  │   │
│  └──────────────────┘        │  │  Linux Web App     │  │   │
│                               │  │  (Public: Disabled)│  │   │
│                               │  └────────────────────┘  │   │
│                               └─────────────────────────┘   │
│                                                               │
│  Private DNS Zone: privatelink.azurewebsites.net            │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **Virtual Network** with a subnet for the private endpoint
2. **Private DNS Zone** (recommended): `privatelink.azurewebsites.net`
3. **Resource Group** for deployment
4. **Log Analytics Workspace** for diagnostic logs
5. **Premium App Service Plan SKU** (P1v3 or higher)

## Quick Start

### 1. Configure Variables

Copy the example tfvars file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Update Required Values

Edit `terraform.tfvars` and replace the placeholder values:

- `resource_group_name` - Your resource group name
- `log_analytics_workspace_id` - Your Log Analytics workspace ID
- `private_endpoint.subnet_id` - **CRITICAL**: Subnet for the private endpoint
- `private_endpoint.private_dns_zone_ids` - (Optional) Private DNS zone IDs

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Important Configuration

### Private Endpoint Subnet

The subnet for the private endpoint must:
- Be in the same region as the web app
- Have sufficient IP addresses (minimum /28 recommended)
- Have private endpoint network policies disabled (handled automatically by Terraform)

Example subnet configuration:
```hcl
private_endpoint = {
  enabled  = true
  subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-privateendpoints"
  private_dns_zone_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
  ]
}
```

### Private DNS Zone

For automatic DNS resolution, link your Private DNS Zone to your VNet:
1. Create Private DNS Zone: `privatelink.azurewebsites.net`
2. Link to your Virtual Network
3. Provide the zone ID in `private_endpoint.private_dns_zone_ids`

Without Private DNS, you'll need to manually configure DNS or use the private IP address.

## Access Patterns

### From Azure VNet
```bash
# Access via private endpoint (requires DNS configuration)
curl https://app-webapp-prod-eastus-001.azurewebsites.net

# Access via private IP (if DNS not configured)
curl https://10.0.1.10
```

### From On-Premises
Requires VPN or ExpressRoute connection to the Azure VNet.

### Public Internet
❌ **Not accessible** - Public network access is disabled.

## Security Considerations

1. **Network Isolation**: App is only accessible from your VNet or connected networks
2. **No Public IP**: Web app has no public IP address
3. **Managed Identity**: Use for secure access to Azure resources (Key Vault, Storage, etc.)
4. **Diagnostic Logs**: All activity logged to Log Analytics for auditing

## Troubleshooting

### Cannot Connect to Web App
- Verify you're connecting from within the VNet or via VPN/ExpressRoute
- Check NSG rules on the subnet
- Verify private DNS resolution: `nslookup app-webapp-prod-eastus-001.azurewebsites.net`

### DNS Not Resolving
- Ensure Private DNS Zone is linked to your VNet
- Verify `private_dns_zone_ids` is configured correctly
- Check DNS zone records for the private endpoint

### Deployment Fails
- Ensure App Service Plan is Premium (P1v3 or higher)
- Verify subnet has available IP addresses
- Check you have required permissions for private endpoint creation

## Cost Considerations

- **Premium App Service Plan**: Higher cost than Basic/Standard tiers
- **Private Endpoint**: ~$7.30/month per endpoint
- **Data Processing**: Ingress free, egress charged per GB

## Next Steps

- Configure custom domain with private certificate
- Set up Application Gateway for internal load balancing
- Integrate with Azure Key Vault for secrets management
- Configure automated deployments via Azure DevOps or GitHub Actions

## Related Examples

- [External-Facing](../external-facing/) - Public-facing deployment with public network access

## Resources

- [Azure Private Link Documentation](https://docs.microsoft.com/azure/private-link/)
- [App Service Private Endpoint](https://docs.microsoft.com/azure/app-service/networking/private-endpoint)
- [Private DNS Zones](https://docs.microsoft.com/azure/dns/private-dns-overview)
