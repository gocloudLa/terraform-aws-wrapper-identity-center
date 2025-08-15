locals {

  # CUSTOMER MANAGED POLICIES
  # Pending

  # MANAGED POLICIES
  aws_managed_policies_tmp = [for key, value in var.identity_permission_sets :
    {
      for managed_policy_arn in value.aws_managed_policies :
      "${key}-${managed_policy_arn}" =>
      {
        "permission_set"     = key
        "managed_policy_arn" = managed_policy_arn
      }
    } if length(try(value.aws_managed_policies, {})) > 0
  ]
  aws_managed_policies = merge(local.aws_managed_policies_tmp...)

  # INLINE POLICIES
  inline_policies = { for key, value in var.identity_permission_sets :
    key => value.inline_policies
    if length(try(value.inline_policies, {})) > 0
  }

  # TARGET ACCOUNTS
  identity_target_accounts_tmp = [for key, value in local.identity_target_accounts_object : # in this line, we reference the key and content of variable
    {
      for key1, value1 in value :                  # in this line, we reference the the key and values inside the content of the first line
      "${key}-${key1}-${value1.permission_set}" => # in this line, we use a custom key to avoid grouping variables with same names
      {
        "account_name"   = key                   # this key is from the first for
        "group"          = key1                  # this key is from the second for
        "permission_set" = value1.permission_set # this key is from the value from the second for
      }
    }
  ]
  identity_target_accounts = merge(local.identity_target_accounts_tmp...)

}