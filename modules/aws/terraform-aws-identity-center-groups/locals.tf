locals {

  user_group_membership_tmp = [for key, value in var.identity_groups :
    {
      for user in value.users :
      "${key}-${user}" =>
      {
        "group" = key
        "user"  = user
      }
    }
  ]
  user_group_membership = merge(local.user_group_membership_tmp...)
}