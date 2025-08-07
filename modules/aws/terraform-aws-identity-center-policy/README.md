## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssoadmin_account_assignment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_managed_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_identity_center"></a> [enable\_identity\_center](#input\_enable\_identity\_center) | Enables or disables the organization service | `bool` | `false` | no |
| <a name="input_identity_groups"></a> [identity\_groups](#input\_identity\_groups) | A map of account that will be created under an organization or OU | `any` | `{}` | no |
| <a name="input_identity_permission_sets"></a> [identity\_permission\_sets](#input\_identity\_permission\_sets) | A list of principal services that will be enable at an organization level | `any` | `{}` | no |
| <a name="input_identity_target_accounts"></a> [identity\_target\_accounts](#input\_identity\_target\_accounts) | despues | `any` | `{}` | no |
| <a name="input_identity_users"></a> [identity\_users](#input\_identity\_users) | A map of account that will be created under an organization or OU | `any` | `{}` | no |
| <a name="input_inline_policies"></a> [inline\_policies](#input\_inline\_policies) | A map of OUs that will be created | `any` | `{}` | no |
| <a name="input_organization_account_ids"></a> [organization\_account\_ids](#input\_organization\_account\_ids) | A map of account that will be created under an organization or Organization Unit | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_attachment_ids"></a> [account\_attachment\_ids](#output\_account\_attachment\_ids) | n/a |
| <a name="output_default_managed_permission_set_policy_ids"></a> [default\_managed\_permission\_set\_policy\_ids](#output\_default\_managed\_permission\_set\_policy\_ids) | n/a |
| <a name="output_default_managed_permission_set_policy_name"></a> [default\_managed\_permission\_set\_policy\_name](#output\_default\_managed\_permission\_set\_policy\_name) | n/a |
| <a name="output_inline_permission_set_policy_id"></a> [inline\_permission\_set\_policy\_id](#output\_inline\_permission\_set\_policy\_id) | n/a |
| <a name="output_permission_set_arns"></a> [permission\_set\_arns](#output\_permission\_set\_arns) | n/a |
| <a name="output_permission_set_creation_dates"></a> [permission\_set\_creation\_dates](#output\_permission\_set\_creation\_dates) | n/a |
| <a name="output_permission_set_ids"></a> [permission\_set\_ids](#output\_permission\_set\_ids) | n/a |
