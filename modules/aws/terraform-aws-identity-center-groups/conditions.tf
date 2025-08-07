locals {
  # FIX - Sin esto falla el condicional siguiente cuando los campos del objeto difieren en numero
  identity_users_tmp = {
    for key, value in var.identity_users : "${key}" => merge(
      {
        optional = {
          timezone = "America/Argentina/Buenos_Aires"
        }
        addresses     = {}
        phone_numbers = {}
    }, value)
  }
  identity_users = var.enable_identity_center ? local.identity_users_tmp : {}

  identity_groups = var.enable_identity_center ? var.identity_groups : {}
}
