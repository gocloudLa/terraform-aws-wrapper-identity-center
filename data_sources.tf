data "aws_ssoadmin_instances" "this" {}

data "aws_identitystore_group" "external" {
  for_each          = toset(lookup(var.identity_center_parameters, "external_identity_groups", []))
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value
    }
  }
}


