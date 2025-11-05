# AWS IAM Identity Center Google Workspace Integration Module

This Terraform module deploys a Lambda function that synchronizes Google Workspace users and groups with AWS IAM Identity Center using the official `ssosync` binary from AWS Labs.

## 🎯 Features

- ✅ **Official AWS Labs SSOSync Binary**: Uses a pre-packaged binary placed at `dist/bootstrap.zip`
- ✅ **Lambda Runtime provided.al2023**: Direct binary execution without Python wrappers
- ✅ **AWS Secrets Manager Integration**: Secure credential storage with external ARN support
- ✅ **EventBridge Scheduling**: Automated synchronization with configurable schedules
- ✅ **IAM Least Privilege**: Minimal permissions required for synchronization
- ✅ **Flexible Secret Management**: Use existing secrets or create new ones automatically
- ✅ **Conditional Resource Creation**: Only creates resources when `enable_google_workspace = true`

## 📋 Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- AWS IAM Identity Center configured
- Google Workspace with API access enabled
- Google Service Account with appropriate permissions

## 🚀 Quick Start

```hcl
module "google_workspace_integration" {
  source = "./modules/aws/terraform-aws-identity-center-google-workspace"

  # General Configuration
  enable_google_workspace = true
  name_prefix            = "my-company"

  # Google Workspace Configuration
  google_workspace_domain = "company.com"
  google_admin_email      = "admin@company.com"
  google_service_account_key = jsonencode({
    "type": "service_account",
    "project_id": "your-project-id",
    "private_key_id": "key-id",
    "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
    "client_email": "service-account@your-project.iam.gserviceaccount.com",
    "client_id": "client-id",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/service-account%40your-project.iam.gserviceaccount.com"
  })

  # SCIM Configuration
  scim_endpoint_url = "https://scim.us-east-1.amazonaws.com/your-instance-id/scim/v2"
  scim_access_token = "your-scim-access-token-from-aws-sso"

  # SSOSync Configuration
  sync_schedule   = "rate(1 hours)"
  sync_method     = "groups"
  log_level       = "info"
  log_format      = "json"
  group_match     = "name:AWS*"
  user_match      = "*"
  ignore_users    = ["test-user@company.com"]
  ignore_groups   = ["Test-Group"]
  include_groups  = []
  dry_run         = false

  tags = {
    Environment = "production"
    Project     = "identity-center"
  }
}
```

## 🔧 Using External Secrets Manager ARNs

If you have existing secrets in AWS Secrets Manager, you can provide their ARNs instead of creating new ones:

```hcl
module "google_workspace_integration" {
  source = "./modules/aws/terraform-aws-identity-center-google-workspace"

  enable_google_workspace = true
  name_prefix            = "my-company"

  # External Secrets Manager ARNs
  google_service_account_key_secretsmanager_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-company/google-credentials-abc123"
  scim_access_token_secretsmanager_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-company/scim-token-def456"
  google_admin_email_secretsmanager_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-company/admin-email-ghi789"
  scim_endpoint_url_secretsmanager_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-company/scim-endpoint-jkl012"
  region_secretsmanager_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-company/region-mno345"
  identity_store_id_secretsmanager_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-company/identity-store-pqr678"

  # SSOSync Configuration
  sync_schedule   = "rate(1 hours)"
  sync_method     = "groups"
  log_level       = "info"
  log_format      = "json"
  group_match     = "name:AWS*"
  user_match      = "*"
  ignore_users    = ["test-user@company.com"]
  ignore_groups   = ["Test-Group"]
  include_groups  = []
  dry_run         = false

  tags = {
    Environment = "production"
    Project     = "identity-center"
  }
}
```

## 📖 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `enable_google_workspace` | Enable Google Workspace integration with IAM Identity Center | `bool` | `false` | no |
| `name_prefix` | Prefix for resource names | `string` | `"identity-center"` | no |
| `tags` | A map of tags to add to all resources | `map(string)` | `{}` | no |
| `google_workspace_domain` | Google Workspace domain (e.g., company.com) | `string` | `""` | no |
| `google_service_account_key` | Google Service Account JSON key for API access | `string` | `""` | no |
| `google_admin_email` | Google Workspace admin email for ssosync | `string` | `""` | no |
| `scim_endpoint_url` | SCIM endpoint URL for ssosync | `string` | `""` | no |
| `scim_access_token` | SCIM access token for ssosync | `string` | `""` | no |
| `google_service_account_key_secretsmanager_arn` | ARN of existing Secrets Manager secret for Google Service Account key | `string` | `""` | no |
| `scim_access_token_secretsmanager_arn` | ARN of existing Secrets Manager secret for SCIM access token | `string` | `""` | no |
| `google_admin_email_secretsmanager_arn` | ARN of existing Secrets Manager secret for Google admin email | `string` | `""` | no |
| `scim_endpoint_url_secretsmanager_arn` | ARN of existing Secrets Manager secret for SCIM endpoint URL | `string` | `""` | no |
| `region_secretsmanager_arn` | ARN of existing Secrets Manager secret for AWS region | `string` | `""` | no |
| `identity_store_id_secretsmanager_arn` | ARN of existing Secrets Manager secret for Identity Store ID | `string` | `""` | no |
| - | - | - | - | - |
| `sync_schedule` | CloudWatch Events schedule expression for synchronization | `string` | `"rate(15 minutes)"` | no |
| `sync_method` | Synchronization method: 'groups' or 'users_groups' | `string` | `"groups"` | no |
| `log_level` | Log level for ssosync (debug, info, warn, error) | `string` | `"info"` | no |
| `log_format` | Log format for ssosync (text, json) | `string` | `"json"` | no |
| `group_match` | Group filter pattern for ssosync (e.g., 'name:AWS*', '*') | `string` | `"*"` | no |
| `user_match` | User filter pattern for ssosync (e.g., 'name:AWS*', '*') | `string` | `"*"` | no |
| `ignore_users` | List of users to ignore during synchronization | `list(string)` | `[]` | no |
| `ignore_groups` | List of groups to ignore during synchronization | `list(string)` | `[]` | no |
| `include_groups` | List of groups to include during synchronization | `list(string)` | `[]` | no |
| `dry_run` | Enable dry-run mode for testing without making changes | `bool` | `false` | no |


## 🔐 Security

### Secrets Manager Integration

This module **always** uses AWS Secrets Manager for sensitive data. You have two options:

1. **External Secrets**: Provide ARNs of existing secrets
2. **Internal Secrets**: Let the module create secrets automatically

### IAM Permissions

The Lambda function receives minimal IAM permissions:

- **Identity Store Access**: Required permissions for user/group synchronization
- **Secrets Manager Access**: Access to specific secrets (external or internal)
- **CloudWatch Logs**: Logging permissions

### Environment Variables

All sensitive data is passed as Secrets Manager ARNs to the Lambda function:

```hcl
environment {
  variables = {
    GOOGLE_ADMIN       = "arn:aws:secretsmanager:region:account:secret:name"
    GOOGLE_CREDENTIALS = "arn:aws:secretsmanager:region:account:secret:name"
    SCIM_ENDPOINT      = "arn:aws:secretsmanager:region:account:secret:name"
    SCIM_ACCESS_TOKEN  = "arn:aws:secretsmanager:region:account:secret:name"
    REGION             = "arn:aws:secretsmanager:region:account:secret:name"
    IDENTITY_STORE_ID  = "arn:aws:secretsmanager:region:account:secret:name"
    # ... other configuration variables
  }
}
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   EventBridge   │───▶│   Lambda Function │───▶│  AWS IAM Identity   │
│   (Scheduler)   │    │   (ssosync)       │    │      Center         │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │ Secrets Manager  │
                       │   (Credentials)  │
                       └──────────────────┘
                                ▲
                                │
                       ┌──────────────────┐
                       │ Google Workspace │
                       │      API         │
                       └──────────────────┘
```

## 📝 Prerequisites

### AWS IAM Identity Center Setup

1. Enable AWS IAM Identity Center
2. Go to **Settings** → **Provisioning**
3. Enable **Automatic provisioning**
4. Copy the **SCIM endpoint URL** and **Access token**

### Google Workspace Setup

1. Enable Google Workspace Admin SDK
2. Create a Service Account with the following roles:
   - **Admin SDK API User**
   - **Directory API User**
3. Generate a JSON key for the Service Account
4. Grant domain-wide delegation to the Service Account

### Required Google Workspace APIs

- Admin SDK API
- Directory API
- Group Settings API

## 🔄 Synchronization Process

The module creates a Lambda function that:

1. **Downloads** the official `ssosync` binary from GitHub releases
2. **Extracts** and packages the binary for Lambda deployment
3. **Runs** on a schedule defined by `sync_schedule`
4. **Synchronizes** users and groups based on `sync_method`:
   - `groups`: Only synchronize groups
   - `users_groups`: Synchronize both users and groups
5. **Filters** data based on `group_match`, `user_match`, `ignore_*`, and `include_*` patterns
6. **Logs** all activities to CloudWatch Logs

## 🐛 Troubleshooting

### Common Issues

1. **Lambda Package Error**: Ensure `dist/bootstrap.zip` exists and is a valid zip containing a `bootstrap` binary
2. **Permission Denied**: Check IAM permissions for Identity Store and Secrets Manager
3. **Google API Errors**: Verify Service Account permissions and domain-wide delegation
4. **SCIM Errors**: Confirm SCIM endpoint URL and access token are correct

### Debugging

Enable debug logging by setting:
```hcl
log_level = "debug"
log_format = "json"
dry_run = true  # Test without making changes
```

### CloudWatch Logs

Check the CloudWatch log group: `/aws/lambda/{name_prefix}-ssosync`


- [AWS IAM Identity Center Documentation](https://docs.aws.amazon.com/singlesignon/)
- [SSOSync GitHub Repository](https://github.com/awslabs/ssosync)
- [Google Workspace Admin SDK](https://developers.google.com/admin-sdk)
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/)

