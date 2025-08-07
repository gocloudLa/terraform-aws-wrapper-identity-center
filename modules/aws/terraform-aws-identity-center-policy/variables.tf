/*----------------------------------------------------------------------*/
/* General | Variable Definition                                        */
/*----------------------------------------------------------------------*/

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

/*----------------------------------------------------------------------*/
/* Identity Center | Variable Definition                                */
/*----------------------------------------------------------------------*/

variable "enable_identity_center" {
  description = "Enables or disables the organization service"
  type        = bool
  default     = false
}
variable "identity_permission_sets" {
  description = "A list of principal services that will be enable at an organization level"
  type        = any
  default     = {}
}
variable "identity_target_accounts" {
  description = "despues"
  type        = any
  default     = {}
}
variable "inline_policies" {
  description = "A map of OUs that will be created"
  type        = any
  default     = {}
}
variable "identity_groups" {
  description = "A map of account that will be created under an organization or OU"
  type        = any
  default     = {}
}
variable "identity_users" {
  description = "A map of account that will be created under an organization or OU"
  type        = any
  default     = {}
}
variable "organization_account_ids" {
  description = "A map of account that will be created under an organization or Organization Unit"
  type        = any
  default     = {}
}