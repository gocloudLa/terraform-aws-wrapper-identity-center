module "wrapper_identity_center" {
  source = "../../"

  metadata = local.metadata

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

    # # If you have existing groups created externally
    # external_identity_groups = [
    #  "ExternalGroup1"
    # ]

    # # If you have existing accounts created externally
    # external_organization_account_ids = {
    #   "Account_1_Name" = "000000000001"
    #   "Account_2_Name" = "000000000002"
    # }

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
      # ${local.metadata.public_domain} --> Generic
      "sample-root" = {
        "CloudAdministrator" = {
          permission_set = "Admin"
        }
        "CloudEngineer" = {
          permission_set = "ReadOnly"
        }
      }
      # NEW
      # ${local.metadata.public_domain} --> Generic
      "sample-dev" = {
        "CloudAdministrator" = {
          permission_set = "Admin"
        }
        "CloudEngineer" = {
          permission_set = "Admin"
        }
        # If you have existing groups created externally
        #"ExternalGroup1" = {
        #  permission_set = "Admin"
        #}
      }
    }

    # sso_sync = {
    #   # General Configuration
    #   enable_google_workspace = true
    #   name_prefix            = "company"

    #   # Google Workspace Configuration
    #   google_workspace_domain = "company.com"
    #   google_admin_email      = "admin@company.com"
    #   google_service_account_key = jsonencode({
    #     # This should contain the actual Google Service Account JSON key
    #     # Example structure:
    #     # {
    #     #   "type": "service_account",
    #     #   "project_id": "your-project-id",
    #     #   "private_key_id": "key-id",
    #     #   "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
    #     #   "client_email": "service-account@your-project.iam.gserviceaccount.com",
    #     #   "client_id": "client-id",
    #     #   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    #     #   "token_uri": "https://oauth2.googleapis.com/token",
    #     #   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    #     #   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/service-account%40your-project.iam.gserviceaccount.com"
    #     # }
    #   })

    #   # SCIM Configuration (Required by ssosync)
    #   # Get these values from AWS SSO console:
    #   # 1. Go to AWS IAM Identity Center > Settings > Provisioning
    #   # 2. Enable automatic provisioning
    #   # 3. Copy the SCIM endpoint URL and access token
    #   scim_endpoint_url = "https://scim.us-east-1.amazonaws.com/your-instance-id/scim/v2"
    #   scim_access_token = "your-scim-access-token-from-aws-sso"

    #   # Optional: Use existing Secrets Manager ARNs instead of creating new secrets
    #   # google_service_account_key_secretsmanager_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/google-credentials"
    #   # scim_access_token_secretsmanager_arn          = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/scim-token"
    #   # google_admin_email_secretsmanager_arn         = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/admin-email"
    #   # scim_endpoint_url_secretsmanager_arn          = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/scim-endpoint"
    #   # region_secretsmanager_arn                     = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/region"
    #   # identity_store_id_secretsmanager_arn          = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/identity-store-id"

    #   # SSOSync Configuration
    #   ssosync_version = "latest"
    #   sync_schedule   = "rate(1 hour)"  # Sync every hour
    #   sync_method     = "groups"        # or "users_groups"
    #   log_level       = "info"
    #   log_format      = "json"
    #   group_match     = "name:AWS*"     # Only sync groups starting with "AWS"
    #   user_match      = "*"             # Sync all users
    #   ignore_users    = []
    #   ignore_groups   = []
    #   include_groups  = []
    #   dry_run         = true            # Set to true for testing
    # }
  }

  # Should come as output from the Organization module that manages the accounts.
  # organization_account_ids = module.wrapper_organization.account_ids
  organization_account_ids = {
    "sample-root" = "111111111111"
    "sample-dev"  = "222222222222"
  }

}