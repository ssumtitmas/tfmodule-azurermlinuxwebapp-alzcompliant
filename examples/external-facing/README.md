# External-Facing Web App Deployment Example

This example demonstrates deploying an ALZ-compliant Azure Linux Web App with **public network access enabled** for external-facing applications.

## 🌐 Overview

This configuration is ideal for:
- Public-facing web applications
- Customer-accessible APIs
- Internet-facing services
- Applications requiring external access

### Key Features

- ✅ **Public Network Access**: Enabled for internet accessibility
- ✅ **No Private Endpoint**: Cost-effective for public workloads
- ✅ **ALZ Compliant**: Follows Azure Landing Zone best practices
- ✅ **HTTPS Only**: Enforced secure connections
- ✅ **TLS 1.2+**: Minimum security requirements
- ✅ **Managed Identity**: System-assigned identity enabled
- ✅ **Diagnostic Logging**: Full monitoring and audit trail

## 🏗️ Architecture

```
Internet
   ↓
Azure Front Door / App Gateway (Optional)
   ↓
Linux Web App (Public Access Enabled)
   ↓
   ├─> Log Analytics Workspace
   └─> Azure Services (via Managed Identity)
```

## 📋 Prerequisites

- Azure subscription with appropriate permissions
- Resource group
- Log Analytics workspace (for ALZ compliance)
- Azure CLI or Azure PowerShell

## 🚀 Quick Start

1. **Copy the example configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your values:
   ```hcl
   workload_name       = "myapp"
   environment         = "prod"
   location            = "East US 2"
   resource_group_name = "rg-myapp-prod-eastus2-001"
   
   log_analytics_workspace_id = "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}"
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Review the plan**:
   ```bash
   terraform plan
   ```

5. **Deploy**:
   ```bash
   terraform apply
   ```

## ⚙️ Configuration Details

### Public Network Access

This example **enables** public network access:

```hcl
public_network_access_enabled = true
```

The web app will be accessible from the internet at:
- `https://{app-name}.azurewebsites.net`

### Private Endpoint

Private endpoint is **disabled** for external deployments:

```hcl
private_endpoint = {
  enabled = false
}
```

### Security Considerations

Even with public access enabled, the module maintains security through:

1. **HTTPS Enforcement**: Only HTTPS traffic allowed
2. **TLS 1.2+**: Modern encryption standards
3. **Managed Identity**: No credential storage needed
4. **Diagnostic Logging**: Full audit trail to Log Analytics
5. **Optional IP Restrictions**: Can be added via `access_restrictions` variable

### Example with IP Restrictions

To add IP-based access control while keeping public access:

```hcl
access_restrictions = [
  {
    name        = "AllowOfficeIP"
    priority    = 100
    ip_address  = "203.0.113.0/24"
    description = "Allow office network"
  },
  {
    name        = "AllowCloudflare"
    priority    = 200
    service_tag = "AzureFrontDoor.Backend"
    description = "Allow Azure Front Door"
  }
]
```

## 📊 Monitoring

The deployment includes comprehensive diagnostics:

- HTTP logs
- Console logs
- Application logs
- Audit logs
- Platform logs
- Metrics

All logs are sent to the specified Log Analytics workspace.

## 🎯 Use Cases

### 1. Public API Service
```hcl
linux_fx_version = "NODE|18-lts"
app_settings = {
  "API_VERSION" = "v1"
  "CORS_ORIGINS" = "https://myapp.com,https://www.myapp.com"
}
```

### 2. Customer Portal
```hcl
linux_fx_version = "DOTNETCORE|8.0"
site_config = {
  health_check_path = "/health"
  always_on = true
}
```

### 3. Marketing Website
```hcl
linux_fx_version = "PHP|8.2"
app_settings = {
  "WEBSITE_RUN_FROM_PACKAGE" = "1"
}
```

## 🔐 ALZ Compliance

This example maintains ALZ compliance through:

- ✅ Diagnostic settings configured
- ✅ ALZ naming conventions
- ✅ Required tags applied
- ✅ HTTPS-only enforcement
- ✅ Managed identity enabled
- ✅ TLS 1.2+ minimum

## 📦 What Gets Deployed

- **App Service Plan**: Premium tier (P1v3) for production workloads
- **Linux Web App**: With public access enabled
- **Diagnostic Settings**: Connected to Log Analytics
- **Managed Identity**: System-assigned identity
- **Tags**: ALZ-compliant resource tags

## 🛠️ Customization

### Change Runtime Stack

```hcl
linux_fx_version = "PYTHON|3.11"  # Python 3.11
# or
linux_fx_version = "DOTNETCORE|8.0"  # .NET 8
# or
linux_fx_version = "JAVA|17-java17"  # Java 17
```

### Add Custom Domain

After deployment, configure custom domain:

```bash
az webapp config hostname add \
  --webapp-name <app-name> \
  --resource-group <rg-name> \
  --hostname www.myapp.com
```

### Enable CDN

For better performance, add Azure CDN or Front Door in front of the web app.

## 🧹 Cleanup

To remove all deployed resources:

```bash
terraform destroy
```

## 📚 Related Examples

- [Internal-Facing](../internal-facing/) - Private deployment with private endpoint

## 📖 Resources

- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [App Service Security](https://docs.microsoft.com/azure/app-service/overview-security)
- [Custom Domains](https://docs.microsoft.com/azure/app-service/app-service-web-tutorial-custom-domain)
- [SSL Certificates](https://docs.microsoft.com/azure/app-service/configure-ssl-certificate)

## 💡 Tips

1. **Use deployment slots** for zero-downtime deployments
2. **Enable Application Insights** for advanced monitoring
3. **Configure autoscaling** for variable workloads
4. **Use Azure Front Door** for global load balancing
5. **Implement rate limiting** at the application level

## ⚠️ Important Notes

- Public access means the app is accessible from the internet
- Consider using Azure Front Door or Application Gateway for additional security
- Always use HTTPS for production workloads
- Monitor access logs regularly for security incidents
- Implement application-level authentication and authorization
