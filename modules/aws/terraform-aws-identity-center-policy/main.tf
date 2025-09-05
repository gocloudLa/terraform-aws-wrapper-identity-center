resource "aws_ssoadmin_permission_set" "this" {
  for_each = local.identity_permission_sets

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  name             = each.key
  description      = lookup(each.value, "description", null)
  relay_state      = lookup(each.value, "relay_state", null)
  session_duration = lookup(each.value, "session_duration", "PT8H")

  tags = var.tags

}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = local.aws_managed_policies

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn
  managed_policy_arn = each.value.managed_policy_arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = local.inline_policies

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = data.aws_iam_policy_document.inline_policies[each.key].json
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.identity_target_accounts

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn
  target_id          = lookup(var.organization_account_ids, each.value.account_name, null)

  principal_id   = var.identity_groups[each.value.group]
  principal_type = "GROUP"
  target_type    = "AWS_ACCOUNT"

}
