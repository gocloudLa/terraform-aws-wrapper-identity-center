output "group_ids" {
  value = tomap({
    for k, group in aws_identitystore_group.this : k => group.group_id
  })
}

output "user_ids" {
  value = tomap({
    for k, user in aws_identitystore_user.this : k => user.user_id
  })
}

output "membership_ids" {
  value = tomap({
    for k, membership in aws_identitystore_group_membership.this : k => membership.membership_id
  })
}

### May need to add the outputs for external_ids of users, for the use case of an identity center using an external services like google or AD