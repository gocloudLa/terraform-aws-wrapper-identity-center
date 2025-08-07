output "account_attachment_ids" {
  value = tomap({
    for k, accoutn_attachment in aws_ssoadmin_account_assignment.this : k => accoutn_attachment.id
  })
}

output "permission_set_arns" {
  value = tomap({
    for k, permission_set in aws_ssoadmin_permission_set.this : k => permission_set.arn
  })
}

output "permission_set_ids" {
  value = tomap({
    for k, permission_set in aws_ssoadmin_permission_set.this : k => permission_set.id
  })
}

output "permission_set_creation_dates" {
  value = tomap({
    for k, permission_set in aws_ssoadmin_permission_set.this : k => permission_set.created_date
  })
}

output "default_managed_permission_set_policy_name" {
  value = tomap({
    for k, default_policy_name in aws_ssoadmin_managed_policy_attachment.this : k => default_policy_name.managed_policy_name
  })
}

output "default_managed_permission_set_policy_ids" {
  value = tomap({
    for k, permissiont_set_policy in aws_ssoadmin_managed_policy_attachment.this : k => permissiont_set_policy.id
  })
}

output "inline_permission_set_policy_id" {
  value = tomap({
    for k, permissiont_set_policy in aws_ssoadmin_permission_set_inline_policy.this : k => permissiont_set_policy.id
  })
}
