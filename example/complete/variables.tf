/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

# variable "metadata" {
#   type = any
# }

# variable "project" {
#   type = string
# }

/*----------------------------------------------------------------------*/
/* Organization | Variable Definition                                   */
/*----------------------------------------------------------------------*/

variable "identity_center_parameters" {
  description = "Identity center parameteres to configure users and policies for organization accounts"
  type        = any
  default     = {}
}