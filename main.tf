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