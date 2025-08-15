# Nota importante!
En caso que desde la cuenta de AWS se esté usando Identity Center por primera vez es necesario hacer un paso manual desde la consola, el cual es darle al botón de "Enable" que está disponible desde el home de la página del servicio.

Una vez hecho esto, se puede proceder con la documentación.

# Documentation

## Introducción

El Wrapper de Terraform para Identity Center.

**Diagrama** <br/>
A continuación se puede ver una imagen que muestra la totalidad de recursos que se pueden desplegar con el wrapper:

<center>![alt text](diagrams/main.png)</center>

---

## Modo de Uso
```hcl
  identity_center_parameters = {
    enable_identity_center = true

    identity_users = {
      "${local.metadata.key.company}-user1" = {
        display_name = "Nombre Apellido"
        optional     = {}
        name = {
          given_name  = "Nombre"
          family_name = "Apellido"
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

<details>
<summary>Tabla de Variables</summary>

| Variable                 | Description                                                                       | Type   | Default | Alternatives |
|--------------------------|-----------------------------------------------------------------------------------|--------|---------|--------------|
| enable_identity_center   | Enables or disables the organization service                                      | `bool` | `false` | no           |
| identity_groups          | A list of principal services that will be enabled at an organization level        | `any`  | `{}`    | no           |
| identity_users           | A list of principal services that will be enabled at an organization level        | `any`  | `{}`    | no           |
| identity_permission_sets | A list of principal services that will be enabled at an organization level        | `any`  | `{}`    | no           |
| identity_target_accounts | To be defined later                                                               | `any`  | `{}`    | no           |
| organization_account_ids | A map of accounts that will be created under an organization or Organization Unit | `any`  | `{}`    | no           |


</details>
---

