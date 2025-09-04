locals {
  external_identity_groups_ids = tomap({
    for k, group in data.aws_identitystore_group.external : k => group.group_id
  })

  identity_group_ids = merge(module.identity_center_groups.group_ids, local.external_identity_groups_ids)

  external_organization_account_ids = try(var.identity_center_parameters["external_organization_account_ids"], {})
  organization_account_ids          = merge(var.organization_account_ids, local.external_organization_account_ids)

}
