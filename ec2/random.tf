resource "random_password" "jump_db" {
  count            = var.enable_jump && var.jump_db_password == null ? 1 : 0
  length           = 32
  special          = true
  override_special = "!@#$%^&*()_+-=[]{}|;:,.<>?"
}

resource "random_password" "jump_redis" {
  count            = var.enable_jump && var.jump_redis_password == null ? 1 : 0
  length           = 24
  special          = true
  override_special = "!@#$%^&*()_+-=[]{}|;:,.<>?"
}
