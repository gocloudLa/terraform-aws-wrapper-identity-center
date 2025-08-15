/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* Organization | Variable Definition                                   */
/*----------------------------------------------------------------------*/

variable "identity_center_parameters" {
  description = "Identity center parameteres to configure users and policies for organization accounts"
  type        = any
  default     = {}
}

variable "organization_account_ids" {
  description = "A map of account that will be created under an organization or Organization Unit"
  type        = any
  default     = "{}"
}