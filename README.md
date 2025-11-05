# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform Identity Center Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-identity-center/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-identity-center.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-identity-center.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-identity-center/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform wrapper for Identity Center simplifies the configuration of AWS Identity Center in the AWS cloud. This wrapper functions as a predefined template, facilitating the creation and management of users, groups, permission sets, and account assignments by handling all the technical details.

### ✨ Features

- 🔄 [SSO Sync](#sso-sync) - Synchronizes Google Workspace users and groups with AWS Identity Center using ssosync




## 🚀 Quick Start
```hcl
identity_center_parameters = {
    enable_identity_center = true

    identity_users = {
      "${local.metadata.key.company}-user1" = {
        display_name = "FirstName LastName"
        optional     = {}
        name = {
          given_name  = "FirstName"
          family_name = "LastName"
        }
        emails = {
          primary = true
          value   = "user@domain.com"
        }
        addresses     = {}
        phone_numbers = {}
      }
    }

    identity_groups = {
      "CloudAdministrator" = {
        description = "This group is for users that will have Administrator Access to the different accounts in the Organization"
        users = [
          "${local.metadata.key.company}-user1"
        ]
      }
      "CloudEngineer" = {
        description = "This group is for users that will have Developer access in the different accounts and Administrator Access in the Workload accounts"
        users = [
        ]
      }
    }

    external_identity_groups = [
      "ExternalGroup1"
    ]

    identity_permission_sets = {
      "Admin" = {
        aws_managed_policies = [
          "arn:aws:iam::aws:policy/AdministratorAccess",
          "arn:aws:iam::aws:policy/job-function/Billing"
        ]
        description      = "Administrator and Billing permission Set"
        relay_state      = null
        session_duration = "PT8H"
      }
      "ReadOnly" = {
        inline_policies = {
          "S3List" = {
            effect = "Allow",
            actions = [
              "s3:ListBucket",
              "s3:ListAllMyBuckets"
            ],
            resources = [
              "*"
            ]
          },
          "S3" = {
            effect = "Allow",
            actions = [
              "s3:GetObject",
              "s3:PutObject",
              "s3:DeleteObject",
              "s3:GetObjectVersion",
              "s3:GetBucketPolicy",
              "s3:GetBucketAcl",
              "s3:GetBucketVersioning",
              "s3:GetLifecycleConfiguration"
            ],
            resources = [
              "arn:aws:s3:::*",
              "arn:aws:s3:::*/*",
            ]
          }
        }
        aws_managed_policies = [
          "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
          "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
          "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess",
          "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
          "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
          "arn:aws:iam::aws:policy/AWSLambda_ReadOnlyAccess"
        ]
        description      = "EC2, SQS and Cloudwatch Read Only permission Set + S3 Read/Write"
        relay_state      = "https://us-east-2.console.aws.amazon.com/cloudwatch/"
        session_duration = "PT8H"
      }
    }

    identity_target_accounts = {
      # ROOT
      "${local.metadata.public_domain}" = {
        "CloudAdministrator" = {
          permission_set = "Admin"
        }
        "CloudEngineer" = {
          permission_set = "ReadOnly"
        }
      }
      # NEW
      "${local.metadata.public_domain}-dev" = {
        "CloudAdministrator" = {
          permission_set = "Admin"
        }
        "CloudEngineer" = {
          permission_set = "Admin"
        }
        "ExternalGroup1" = {
          permission_set = "Admin"
        }
      }
    }
  }
```


## 🔧 Additional Features Usage

### SSO Sync
Automatically synchronizes Google Workspace users and groups with AWS Identity Center using ssosync. This feature deploys a Lambda function that periodically syncs your Google Workspace directory with AWS Identity Center, keeping user and group memberships in sync. Supports configurable sync schedules, filtering options, and integration with AWS Secrets Manager for secure credential storage.


<details><summary>Configuration Code</summary>

```hcl
identity_center_parameters = {
  sso_sync = {
    # General Configuration
    enable_google_workspace = true
    name_prefix            = "company"

    # Google Workspace Configuration
    google_workspace_domain = "company.com"
    google_admin_email      = "admin@company.com"
    google_service_account_key = jsonencode({
      # Google Service Account JSON key
    })

    # SCIM Configuration
    scim_endpoint_url = "https://scim.us-east-1.amazonaws.com/your-instance-id/scim/v2"
    scim_access_token = "your-scim-access-token-from-aws-sso"

    # Note: The module automatically creates Secrets Manager secrets for secure storage
    # of credentials. If you prefer to use existing external secrets, you can reference
    # them by providing the following ARNs instead:

    # Optional: Use existing Secrets Manager ARNs instead of creating new secrets
    # google_service_account_key_secretsmanager_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/google-credentials"
    # scim_access_token_secretsmanager_arn          = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/scim-token"
    # google_admin_email_secretsmanager_arn         = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/admin-email"
    # scim_endpoint_url_secretsmanager_arn          = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/scim-endpoint"
    # region_secretsmanager_arn                     = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/region"
    # identity_store_id_secretsmanager_arn          = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/identity-store-id"

    # SSOSync Configuration
    sync_schedule   = "rate(1 hour)"  # Sync every hour
    sync_method     = "groups"        # or "users_groups"
    log_level       = "info"
    log_format      = "json"
    group_match     = "name:AWS*"     # Only sync groups starting with "AWS"
    user_match      = "*"             # Sync all users
    ignore_users    = []
    ignore_groups   = []
    include_groups  = []
    dry_run         = false           # Set to true for testing
  }
}
```


</details>




## 📑 Inputs
| Name                     | Description                                                                               | Type   | Default | Required |
| ------------------------ | ----------------------------------------------------------------------------------------- | ------ | ------- | -------- |
| enable_identity_center   | Enables or disables the organization service                                              | `bool` | `false` | no       |
| identity_groups          | A list of principal services that will be enabled at an organization level                | `any`  | `{}`    | no       |
| identity_users           | A list of principal services that will be enabled at an organization level                | `any`  | `{}`    | no       |
| identity_permission_sets | A list of principal services that will be enabled at an organization level                | `any`  | `{}`    | no       |
| identity_target_accounts | To be defined later                                                                       | `any`  | `{}`    | no       |
| sso_sync                 | Configuration for Google Workspace synchronization with AWS Identity Center using ssosync | `any`  | `{}`    | no       |
| organization_account_ids | A map of accounts that will be created under an organization or Organization Unit         | `any`  | `{}`    | no       |







## ⚠️ Important Notes
- **ℹ️ Enable Service:** The AWS Identity Center service must be enabled, before using the module
- **ℹ️ SSO Sync Lambda Deployment:** It is normal for the ssosync Lambda function to attempt deployment multiple times during the initial setup. This occurs because the Lambda package is automatically downloaded from the internet and built, which may require multiple attempts to complete successfully.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 