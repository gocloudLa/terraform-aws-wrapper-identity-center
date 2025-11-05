module "google_workspace_integration" {

  source = "../../"

  # General Configuration
  enable_google_workspace = true
  name_prefix            = "company"

  # Google Workspace Configuration
  google_workspace_domain   = "company.com"
  google_admin_email        = "admin@company.com"
  google_service_account_key = jsonencode({
    # Provide a valid Google Service Account key JSON here
    # Example structure:
    # {
    #   "type": "service_account",
    #   "project_id": "your-project-id",
    #   "private_key_id": "key-id",
    #   "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
    #   "client_email": "service-account@your-project.iam.gserviceaccount.com",
    #   "client_id": "client-id",
    #   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    #   "token_uri": "https://oauth2.googleapis.com/token",
    #   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    #   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/service-account%40your-project.iam.gserviceaccount.com"
    # }
  })

  # SCIM Configuration (from AWS IAM Identity Center > Settings > Provisioning)
  scim_endpoint_url = "https://scim.us-east-1.amazonaws.com/your-instance-id/scim/v2"
  scim_access_token = "your-scim-access-token-from-aws-sso"

  # Optional: Use existing Secrets Manager ARNs instead of creating new secrets
  # google_service_account_key_secretsmanager_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/google-credentials"
  # scim_access_token_secretsmanager_arn          = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/scim-token"
  # google_admin_email_secretsmanager_arn         = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/admin-email"
  # scim_endpoint_url_secretsmanager_arn          = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/scim-endpoint"
  # region_secretsmanager_arn                     = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/region"
  # identity_store_id_secretsmanager_arn          = "arn:aws:secretsmanager:us-east-1:123456789012:secret:external/identity-store-id"

  # SSOSync Settings
  sync_schedule  = "rate(1 hours)"
  sync_method    = "groups"
  log_level      = "info"
  log_format     = "json"
  group_match    = "name:AWS*"
  user_match     = ""
  ignore_users   = []
  ignore_groups  = []
  include_groups = []
  dry_run        = true

  tags = {
    Environment = "dev"
    Project     = "identity-center"
  }
}


