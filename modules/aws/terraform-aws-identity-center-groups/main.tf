resource "aws_identitystore_user" "this" {
  for_each = local.identity_users

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = each.value.display_name
  user_name         = each.key

  ## Optional
  locale             = try(each.value.optional.locale, null)
  nickname           = try(each.value.optional.nickname, null)
  preferred_language = try(each.value.optional.preferred_language, null)
  profile_url        = try(each.value.optional.profile_url, null)
  timezone           = try(each.value.optional.timezone, null)
  title              = try(each.value.optional.title, null)
  user_type          = try(each.value.optional.user_type, null)

  name {
    family_name      = each.value.name.family_name
    given_name       = each.value.name.given_name
    formatted        = try(each.value.name.formatted, null)
    honorific_prefix = try(each.value.name.honorific_prefix, null)
    honorific_suffix = try(each.value.name.honorific_suffix, null)
    middle_name      = try(each.value.name.middle_name, null)
  }

  phone_numbers {
    primary = try(each.value.phone_numbers.primary, false)
    type    = try(each.value.phone_numbers.type, null)
    value   = try(each.value.phone_numbers.value, null)
  }

  emails {
    primary = try(each.value.emails.primary, false)
    type    = try(each.value.emails.type, null)
    value   = each.value.emails.value
  }

  addresses {
    country        = try(each.value.addresses.country, null)
    formatted      = try(each.value.addresses.formatted, null)
    locality       = try(each.value.addresses.locality, null)
    postal_code    = try(each.value.addresses.postal_code, null)
    primary        = try(each.value.addresses.primary, false)
    region         = try(each.value.addresses.region, null)
    street_address = try(each.value.addresses.street_address, null)
    type           = try(each.value.addresses.type, null)
  }
}

resource "aws_identitystore_group" "this" {
  for_each = local.identity_groups

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = each.key
  description       = try(each.value.description, "")
}

resource "aws_identitystore_group_membership" "this" {
  for_each = local.user_group_membership

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  member_id = aws_identitystore_user.this[each.value.user].user_id
  group_id  = aws_identitystore_group.this[each.value.group].group_id
}
