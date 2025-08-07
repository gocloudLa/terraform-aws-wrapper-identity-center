output "user_ids" {
  value = module.identity_center_groups.user_ids
}

output "group_ids" {
  value = local.identity_group_ids
}

output "permission_set_ids" {
  value = module.identity_center_policies.permission_set_ids
}