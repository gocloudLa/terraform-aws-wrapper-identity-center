locals {
  identity_users = var.enable_identity_center ? var.identity_users : {}

  identity_groups = var.enable_identity_center ? var.identity_groups : {}

  # identity_permission_sets = var.enable_identity_center ? var.identity_permission_sets : {}
  identity_permission_sets = var.identity_permission_sets

  # inline_policies = var.enable_identity_center ? var.inline_policies : {}

  identity_target_accounts_object = var.enable_identity_center ? var.identity_target_accounts : {}
}