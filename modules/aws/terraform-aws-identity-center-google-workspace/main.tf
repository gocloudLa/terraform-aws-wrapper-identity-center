# =============================================================================
# AWS IAM Identity Center Google Workspace Integration Module
# =============================================================================
# This module deploys a Lambda function that synchronizes Google Workspace
# users and groups with AWS IAM Identity Center using the official ssosync
# binary from AWS Labs.
# =============================================================================

# Data sources
data "aws_ssoadmin_instances" "this" {
  count = var.enable_google_workspace ? 1 : 0
}
data "aws_region" "current" {
  count = var.enable_google_workspace ? 1 : 0
}
data "aws_caller_identity" "current" {
  count = var.enable_google_workspace ? 1 : 0
}
data "aws_partition" "current" {
  count = var.enable_google_workspace ? 1 : 0
}


# =============================================================================
# SSOSync Binary Download and Packaging
# =============================================================================
# Downloads the official ssosync binary from GitHub releases and packages it
# for AWS Lambda deployment with the provided.al2023 runtime.

locals {
  # SSOSync version and download configuration
  ssosync_download_url = "https://github.com/awslabs/ssosync/releases/download/${var.ssosync_version}/ssosync_Linux_x86_64.tar.gz"
  download_artifact    = "ssosync_Linux_x86_64.tar.gz"

  # Secrets Manager ARN logic - use external ARNs if provided, otherwise use internal secrets
  google_credentials_arn = var.google_service_account_key_secretsmanager_arn != "" ? var.google_service_account_key_secretsmanager_arn : try(aws_secretsmanager_secret.google_credentials[0].arn, "")
  scim_access_token_arn  = var.scim_access_token_secretsmanager_arn != "" ? var.scim_access_token_secretsmanager_arn : try(aws_secretsmanager_secret.scim_access_token[0].arn, "")
  google_admin_arn       = var.google_admin_email_secretsmanager_arn != "" ? var.google_admin_email_secretsmanager_arn : try(aws_secretsmanager_secret.google_admin[0].arn, "")
  scim_endpoint_arn      = var.scim_endpoint_url_secretsmanager_arn != "" ? var.scim_endpoint_url_secretsmanager_arn : try(aws_secretsmanager_secret.scim_endpoint[0].arn, "")
  region_arn             = var.region_secretsmanager_arn != "" ? var.region_secretsmanager_arn : try(aws_secretsmanager_secret.region[0].arn, "")
  identity_store_id_arn  = var.identity_store_id_secretsmanager_arn != "" ? var.identity_store_id_secretsmanager_arn : try(aws_secretsmanager_secret.identity_store_id[0].arn, "")

  # Determine if we should create internal secrets (only if no external ARN provided)
  create_google_credentials_secret = var.google_service_account_key_secretsmanager_arn == ""
  create_scim_access_token_secret  = var.scim_access_token_secretsmanager_arn == ""
  create_google_admin_secret       = var.google_admin_email_secretsmanager_arn == ""
  create_scim_endpoint_secret      = var.scim_endpoint_url_secretsmanager_arn == ""
  create_region_secret             = var.region_secretsmanager_arn == ""
  create_identity_store_id_secret  = var.identity_store_id_secretsmanager_arn == ""
}

# Download ssosync binary - using curl in local-exec instead of data.http

# Create dist directory and download artifact
resource "null_resource" "download_artifact" {
  count = var.enable_google_workspace ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ${path.module}/tmp && cd ${path.module}/tmp
      curl -s -L -o ${local.download_artifact} "${local.ssosync_download_url}"
    EOT
  }

  triggers = {
    version   = var.ssosync_version
    file_hash = try(filemd5("${path.module}/tmp/${local.download_artifact}"), timestamp())
  }
}

# Extract ssosync binary from tar.gz to dist directory (CloudPosse pattern)
resource "null_resource" "extract_ssosync" {
  count = var.enable_google_workspace ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/tmp
      mkdir -p dist || true
      tar -xzf ${local.download_artifact} -C dist
      if [ -f dist/ssosync ]; then
        mv dist/ssosync dist/bootstrap
      fi
    EOT
  }

  triggers = {
    version   = var.ssosync_version
    file_hash = try(filemd5("${path.module}/tmp/dist/bootstrap"), timestamp())
  }

  depends_on = [null_resource.download_artifact]
}

# Create Lambda package from dist directory
resource "null_resource" "create_lambda_package" {
  count = var.enable_google_workspace ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/tmp/dist
      if [ -f ../bootstrap.zip ]; then
        rm -f ../bootstrap.zip
      fi
      # Fix timestamp to ensure consistent zip hash
      touch -t 202401010000 bootstrap
      zip -q ../bootstrap.zip bootstrap
    EOT
  }

  triggers = {
    version   = var.ssosync_version
    file_hash = try(filemd5("${path.module}/tmp/bootstrap.zip"), timestamp())
  }

  depends_on = [null_resource.extract_ssosync]
}

# =============================================================================
# AWS Secrets Manager Configuration
# =============================================================================
# Creates secrets for sensitive data when use_secretsmanager = true.
# According to ssosync documentation, these variables MUST be stored as secrets:
# - GOOGLE_ADMIN, GOOGLE_CREDENTIALS, SCIM_ENDPOINT, SCIM_ACCESS_TOKEN, 
#   REGION, IDENTITY_STORE_ID
# =============================================================================
resource "aws_secretsmanager_secret" "google_credentials" {
  count = var.enable_google_workspace && local.create_google_credentials_secret ? 1 : 0

  name        = "${var.name_prefix}-google-credentials"
  description = "Google Workspace service account credentials for ssosync"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "google_credentials" {
  count = var.enable_google_workspace && local.create_google_credentials_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.google_credentials[0].id
  secret_string = var.google_service_account_key
}

resource "aws_secretsmanager_secret" "scim_access_token" {
  count = var.enable_google_workspace && local.create_scim_access_token_secret ? 1 : 0

  name        = "${var.name_prefix}-scim-access-token"
  description = "SCIM access token for ssosync"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "scim_access_token" {
  count = var.enable_google_workspace && local.create_scim_access_token_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.scim_access_token[0].id
  secret_string = var.scim_access_token
}

# Additional secrets for variables that must be stored in Secrets Manager
resource "aws_secretsmanager_secret" "google_admin" {
  count = var.enable_google_workspace && local.create_google_admin_secret ? 1 : 0

  name        = "${var.name_prefix}-google-admin"
  description = "Google Workspace admin email for ssosync"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "google_admin" {
  count = var.enable_google_workspace && local.create_google_admin_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.google_admin[0].id
  secret_string = var.google_admin_email
}

resource "aws_secretsmanager_secret" "scim_endpoint" {
  count = var.enable_google_workspace && local.create_scim_endpoint_secret ? 1 : 0

  name        = "${var.name_prefix}-scim-endpoint"
  description = "SCIM endpoint URL for ssosync"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "scim_endpoint" {
  count = var.enable_google_workspace && local.create_scim_endpoint_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.scim_endpoint[0].id
  secret_string = var.scim_endpoint_url
}

resource "aws_secretsmanager_secret" "region" {
  count = var.enable_google_workspace && local.create_region_secret ? 1 : 0

  name        = "${var.name_prefix}-region"
  description = "AWS region for ssosync"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "region" {
  count = var.enable_google_workspace && local.create_region_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.region[0].id
  secret_string = data.aws_region.current[0].id
}

resource "aws_secretsmanager_secret" "identity_store_id" {
  count = var.enable_google_workspace && local.create_identity_store_id_secret ? 1 : 0

  name        = "${var.name_prefix}-identity-store-id"
  description = "AWS IAM Identity Center Identity Store ID for ssosync"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "identity_store_id" {
  count = var.enable_google_workspace && local.create_identity_store_id_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.identity_store_id[0].id
  secret_string = tolist(data.aws_ssoadmin_instances.this[0].identity_store_ids)[0]
}

# =============================================================================
# AWS Lambda Function - Native Implementation
# =============================================================================

# =============================================================================
# CloudWatch Log Group
# =============================================================================

resource "aws_cloudwatch_log_group" "lambda" {
  count = var.enable_google_workspace ? 1 : 0

  name              = "/aws/lambda/${var.name_prefix}-ssosync"
  retention_in_days = 0
  skip_destroy      = false

  tags = var.tags
}

# =============================================================================
# IAM Role and Policies
# =============================================================================

resource "aws_iam_role" "lambda" {
  count = var.enable_google_workspace ? 1 : 0

  name = "${var.name_prefix}-ssosync"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  force_detach_policies = true
  tags                  = var.tags
}

# IAM Policy for Identity Store Access
resource "aws_iam_role_policy" "identity_store" {
  count = var.enable_google_workspace ? 1 : 0

  name = "${var.name_prefix}-ssosync-identity-store"
  role = aws_iam_role.lambda[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IdentityStoreAccess"
        Effect = "Allow"
        Action = [
          "identitystore:ListUsers",
          "identitystore:ListGroups",
          "identitystore:ListGroupMemberships",
          "identitystore:IsMemberInGroups",
          "identitystore:GetGroupMembershipId",
          "identitystore:DeleteUser",
          "identitystore:DeleteGroupMembership",
          "identitystore:DeleteGroup",
          "identitystore:CreateGroupMembership",
          "identitystore:CreateGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for Secrets Manager Access (Always created since we always use Secrets Manager)
resource "aws_iam_role_policy" "secrets_manager" {
  count = var.enable_google_workspace ? 1 : 0

  name = "${var.name_prefix}-ssosync-secrets"
  role = aws_iam_role.lambda[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = compact([
          local.google_credentials_arn,
          local.scim_access_token_arn,
          local.google_admin_arn,
          local.scim_endpoint_arn,
          local.region_arn,
          local.identity_store_id_arn
        ])
      }
    ]
  })
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_role_policy" "logs" {
  count = var.enable_google_workspace ? 1 : 0

  name = "${var.name_prefix}-ssosync-logs"
  role = aws_iam_role.lambda[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current[0].region}:${data.aws_caller_identity.current[0].account_id}:log-group:/aws/lambda/${var.name_prefix}-ssosync:*",
          "arn:aws:logs:${data.aws_region.current[0].region}:${data.aws_caller_identity.current[0].account_id}:log-group:/aws/lambda/${var.name_prefix}-ssosync:*:*"
        ]
      }
    ]
  })
}

# =============================================================================
# Lambda Function
# =============================================================================

resource "aws_lambda_function" "ssosync" {
  count = var.enable_google_workspace ? 1 : 0

  function_name = "${var.name_prefix}-ssosync"
  description   = "Lambda function for SSOSync - Google Workspace to AWS IAM Identity Center synchronization"
  role          = aws_iam_role.lambda[0].arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  timeout       = 300
  memory_size   = 128
  publish       = false

  filename         = null_resource.create_lambda_package[0].triggers.file_hash != "missing" ? "${path.module}/tmp/bootstrap.zip" : null
  source_code_hash = null_resource.create_lambda_package[0].triggers.file_hash != "missing" ? filebase64sha256("${path.module}/tmp/bootstrap.zip") : null

  environment {
    variables = {
      # Secrets - always use ARNs (external or internal)
      GOOGLE_ADMIN       = local.google_admin_arn
      GOOGLE_CREDENTIALS = local.google_credentials_arn
      SCIM_ENDPOINT      = local.scim_endpoint_arn
      SCIM_ACCESS_TOKEN  = local.scim_access_token_arn
      REGION             = local.region_arn
      IDENTITY_STORE_ID  = local.identity_store_id_arn
      # Environments
      LOG_LEVEL      = var.log_level
      LOG_FORMAT     = var.log_format
      SYNC_METHOD    = var.sync_method
      GROUP_MATCH    = var.group_match
      USER_MATCH     = var.user_match
      IGNORE_GROUPS  = join(",", var.ignore_groups)
      IGNORE_USERS   = join(",", var.ignore_users)
      INCLUDE_GROUPS = join(",", var.include_groups)
      DRY_RUN        = var.dry_run
    }
  }

  depends_on = [
    null_resource.create_lambda_package,
    aws_cloudwatch_log_group.lambda
  ]

  tags = var.tags
}

# =============================================================================
# Lambda Permission for EventBridge
# =============================================================================

resource "aws_lambda_permission" "allow_eventbridge" {
  count = var.enable_google_workspace ? 1 : 0

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ssosync[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ssosync_schedule[0].arn
}

# =============================================================================
# EventBridge Rule for Scheduled Execution
# =============================================================================

resource "aws_cloudwatch_event_rule" "ssosync_schedule" {
  count = var.enable_google_workspace ? 1 : 0

  name                = "${var.name_prefix}-ssosync-schedule"
  description         = "Trigger ssosync synchronization"
  schedule_expression = var.sync_schedule != "" && var.sync_schedule != null ? var.sync_schedule : "rate(15 minutes)"

  tags = var.tags
}

# EventBridge target for Lambda function
resource "aws_cloudwatch_event_target" "ssosync_target" {
  count = var.enable_google_workspace ? 1 : 0

  rule = aws_cloudwatch_event_rule.ssosync_schedule[0].name
  arn  = aws_lambda_function.ssosync[0].arn
}
