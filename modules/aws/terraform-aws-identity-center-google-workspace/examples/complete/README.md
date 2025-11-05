## Example: Complete Google Workspace Integration

This example deploys the Google Workspace → AWS IAM Identity Center synchronization using the module in this folder.

Notes:
- The Lambda package is static. Ensure `dist/bootstrap.zip` exists inside the module before applying.
- You can provide existing Secrets Manager ARNs or let the module create the secrets.

Files:
- `providers.tf`: Configures the AWS provider
- `main.tf`: Module invocation with typical settings

Usage:
```bash
terraform init
terraform plan
terraform apply
```


