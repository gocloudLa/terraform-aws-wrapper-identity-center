/*----------------------------------------------------------------------*/
/* General | Variable Definition                                        */
/*----------------------------------------------------------------------*/

variable "enable_google_workspace" {
  description = "Enable Google Workspace integration with IAM Identity Center"
  type        = bool
  default     = false
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "identity-center"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
/*----------------------------------------------------------------------*/
/* Google Workspace Lambda Sync Configuration                           */
/*----------------------------------------------------------------------*/

variable "google_workspace_domain" {
  description = "Google Workspace domain (e.g., company.com)"
  type        = string
  default     = ""
}

variable "google_service_account_key" {
  description = "Google Service Account JSON key for API access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "google_admin_email" {
  description = "Google Workspace admin email for ssosync"
  type        = string
  default     = ""
}

variable "scim_endpoint_url" {
  description = "SCIM endpoint URL for ssosync (empty string for Google Workspace)"
  type        = string
  default     = ""
}

variable "scim_access_token" {
  description = "SCIM access token for ssosync (empty string for Google Workspace)"
  type        = string
  default     = ""
  sensitive   = true
}

/*----------------------------------------------------------------------*/
/* External Secrets Manager ARNs                                        */
/*----------------------------------------------------------------------*/

variable "google_service_account_key_secretsmanager_arn" {
  description = "ARN of existing Secrets Manager secret for Google Service Account key. If provided, module will not create the secret."
  type        = string
  default     = ""
}

variable "scim_access_token_secretsmanager_arn" {
  description = "ARN of existing Secrets Manager secret for SCIM access token. If provided, module will not create the secret."
  type        = string
  default     = ""
}

variable "google_admin_email_secretsmanager_arn" {
  description = "ARN of existing Secrets Manager secret for Google admin email. If provided, module will not create the secret."
  type        = string
  default     = ""
}

variable "scim_endpoint_url_secretsmanager_arn" {
  description = "ARN of existing Secrets Manager secret for SCIM endpoint URL. If provided, module will not create the secret."
  type        = string
  default     = ""
}

variable "region_secretsmanager_arn" {
  description = "ARN of existing Secrets Manager secret for AWS region. If provided, module will not create the secret."
  type        = string
  default     = ""
}

variable "identity_store_id_secretsmanager_arn" {
  description = "ARN of existing Secrets Manager secret for Identity Store ID. If provided, module will not create the secret."
  type        = string
  default     = ""
}

/*----------------------------------------------------------------------*/
/* Lambda Function Configuration                                        */
/*----------------------------------------------------------------------*/

variable "ssosync_version" {
  description = "Version of ssosync to deploy (e.g., 'v2.3.4'). Must be a specific version tag from GitHub releases."
  type        = string
  default     = "v2.3.4"
}

variable "sync_schedule" {
  description = "CloudWatch Events schedule expression for synchronization (e.g., 'rate(1 hour)')"
  type        = string
  default     = "rate(15 minutes)"
}

variable "sync_method" {
  description = "Synchronization method: 'groups' or 'users_groups'"
  type        = string
  default     = "groups"
  validation {
    condition     = contains(["groups", "users_groups"], var.sync_method)
    error_message = "Sync method must be either 'groups' or 'users_groups'."
  }
}

variable "log_level" {
  description = "Log level for ssosync (debug, info, warn, error)"
  type        = string
  default     = "info"
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be one of: debug, info, warn, error."
  }
}

variable "log_format" {
  description = "Log format for ssosync (text, json)"
  type        = string
  default     = "json"
  validation {
    condition     = contains(["text", "json"], var.log_format)
    error_message = "Log format must be either 'text' or 'json'."
  }
}

variable "group_match" {
  description = "Group filter pattern for ssosync (e.g., 'name:AWS*', '*')"
  type        = string
  default     = "*"
}

variable "user_match" {
  description = "User filter pattern for ssosync (e.g., 'name:John*', '*')"
  type        = string
  default     = "*"
}

variable "ignore_users" {
  description = "List of users to ignore during synchronization"
  type        = list(string)
  default     = []
}

variable "ignore_groups" {
  description = "List of groups to ignore during synchronization"
  type        = list(string)
  default     = []
}

variable "include_groups" {
  description = "List of groups to include (users_groups method only)"
  type        = list(string)
  default     = []
}

variable "dry_run" {
  description = "Enable dry-run mode for testing without making changes"
  type        = bool
  default     = false
}

/*----------------------------------------------------------------------*/
/* Secrets Manager Configuration                                        */
/*----------------------------------------------------------------------*/

