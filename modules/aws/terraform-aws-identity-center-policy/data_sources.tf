data "aws_ssoadmin_instances" "this" {}

# data "aws_iam_policy_document" "this" {
#   for_each = local.inline_policies

#   statement {
#     sid       = lookup(each.value, "sid", null)
#     effect    = lookup(each.value, "effect", "Allow")
#     actions   = lookup(each.value, "actions", [])
#     resources = lookup(each.value, "resources", [])

#     dynamic "condition" {
#       for_each = each.value.enable_condition == true ? [1] : []

#       content {
#         test     = lookup(each.value, "test", null)
#         values   = lookup(each.value, "values", null)
#         variable = lookup(each.value, "variable", null)
#       }
#     }
#     dynamic "principals" {
#       for_each = each.value.enable_principal == true ? [1] : []

#       content {
#         identifiers = lookup(each.value, "identifiers", null)
#         type        = lookup(each.value, "type", null)
#       }
#     }

#     not_actions   = lookup(each.value, "not_actions", [])
#     not_resources = lookup(each.value, "not_resources", [])
#     dynamic "not_principals" {
#       for_each = each.value.enable_principal == true ? [1] : []

#       content {
#         identifiers = lookup(each.value, "identifiers", null)
#         type        = lookup(each.value, "type", null)
#       }
#     }
#   }
# }

data "aws_iam_policy_document" "inline_policies" {
  for_each = local.inline_policies

  dynamic "statement" {
    for_each = local.inline_policies[each.key]

    content {
      sid           = try(statement.value.sid, replace(statement.key, "/[^0-9A-Za-z]*/", ""))
      effect        = try(statement.value.effect, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])
        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.condition, [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}