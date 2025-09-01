locals {
  metadata = var.metadata

  common_name = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  common_tags = {
    "company"     = local.metadata.key.company
    "provisioner" = "terraform"
    "environment" = local.metadata.environment
    "created-by"  = "GoCloud.la"
  }

  external_identity_groups_ids = tomap({
    for k, group in data.aws_identitystore_group.external : k => group.group_id
  })

  identity_group_ids = merge(module.identity_center_groups.group_ids, local.external_identity_groups_ids)

  external_organization_account_ids = try(var.identity_center_parameters["external_organization_account_ids"], {})
  organization_account_ids          = merge(var.organization_account_ids, local.external_organization_account_ids)

}
