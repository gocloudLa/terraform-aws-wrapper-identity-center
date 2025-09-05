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
  }

  # Should come as output from the Organization module that manages the accounts.
  # organization_account_ids = module.wrapper_organization.account_ids
  organization_account_ids = {
    "sample-root" = "111111111111"
    "sample-dev"  = "222222222222"
  }

}