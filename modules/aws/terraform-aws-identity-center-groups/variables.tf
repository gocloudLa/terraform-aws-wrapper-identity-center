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
variable "identity_users" {
  description = "A list of principal services that will be enable at an organization level"
  type        = any
  default     = {}
}
variable "identity_groups" {
  description = "A list of principal services that will be enable at an organization level"
  type        = any
  default     = {}
}