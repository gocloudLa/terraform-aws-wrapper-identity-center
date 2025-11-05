module "identity_center_groups" {

  source = "./modules/aws/terraform-aws-identity-center-groups"

  enable_identity_center = lookup(var.identity_center_parameters, "enable_identity_center", false)
  identity_groups        = lookup(var.identity_center_parameters, "identity_groups", {})
  identity_users         = lookup(var.identity_center_parameters, "identity_users", {})
}

module "identity_center_policies" {

  source = "./modules/aws/terraform-aws-identity-center-policy"

  enable_identity_center = lookup(var.identity_center_parameters, "enable_identity_center", false)

  identity_groups = local.identity_group_ids

  inline_policies          = lookup(var.identity_center_parameters, "inline_policies", {})
  identity_permission_sets = lookup(var.identity_center_parameters, "identity_permission_sets", {})
  identity_target_accounts = lookup(var.identity_center_parameters, "identity_target_accounts", {})
  organization_account_ids = local.organization_account_ids

  tags = local.common_tags
}

module "google_workspace_integration" {

  source = "./modules/aws/terraform-aws-identity-center-google-workspace"

  # General Configuration
  enable_google_workspace = try(var.identity_center_parameters.sso_sync.enable_google_workspace, false)
  name_prefix            = try(var.identity_center_parameters.sso_sync.name_prefix, "org")
  
  # Google Workspace Configuration
  google_workspace_domain = try(var.identity_center_parameters.sso_sync.google_workspace_domain, "")
  google_admin_email      = try(var.identity_center_parameters.sso_sync.google_admin_email, "")
  google_service_account_key = try(var.identity_center_parameters.sso_sync.google_service_account_key, "")
  
  # SCIM Configuration
  scim_endpoint_url = try(var.identity_center_parameters.sso_sync.scim_endpoint_url, "")
  scim_access_token = try(var.identity_center_parameters.sso_sync.scim_access_token, "")
  
  # External Secrets Manager ARNs (optional)
  google_service_account_key_secretsmanager_arn = try(var.identity_center_parameters.sso_sync.google_service_account_key_secretsmanager_arn, "")
  scim_access_token_secretsmanager_arn = try(var.identity_center_parameters.sso_sync.scim_access_token_secretsmanager_arn, "")
  google_admin_email_secretsmanager_arn = try(var.identity_center_parameters.sso_sync.google_admin_email_secretsmanager_arn, "")
  scim_endpoint_url_secretsmanager_arn = try(var.identity_center_parameters.sso_sync.scim_endpoint_url_secretsmanager_arn, "")
  region_secretsmanager_arn = try(var.identity_center_parameters.sso_sync.region_secretsmanager_arn, "")
  identity_store_id_secretsmanager_arn = try(var.identity_center_parameters.sso_sync.identity_store_id_secretsmanager_arn, "")
  
  # SSOSync Configuration
  sync_schedule   = try(var.identity_center_parameters.sso_sync.sync_schedule, "rate(15 minutes)")
  sync_method     = try(var.identity_center_parameters.sso_sync.sync_method, "groups")
  log_level       = try(var.identity_center_parameters.sso_sync.log_level, "info")
  log_format      = try(var.identity_center_parameters.sso_sync.log_format, "json")
  group_match     = try(var.identity_center_parameters.sso_sync.group_match, "name:AWS*")
  user_match      = try(var.identity_center_parameters.sso_sync.user_match, "")
  ignore_users    = try(var.identity_center_parameters.sso_sync.ignore_users, [])
  ignore_groups   = try(var.identity_center_parameters.sso_sync.ignore_groups, [])
  include_groups  = try(var.identity_center_parameters.sso_sync.include_groups, [])
  dry_run         = try(var.identity_center_parameters.sso_sync.dry_run, true)

  tags = local.common_tags
}