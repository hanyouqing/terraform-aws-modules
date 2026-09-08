locals {
  port = coalesce(var.port, var.engine == "postgres" ? 5432 : 3306)
}

resource "random_password" "master" {
  count   = var.manage_master_user_password || var.password != null ? 0 : 1
  length  = 32
  special = false
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge(local.common_tags, { Name = "${var.identifier}-subnet-group" })
}

resource "aws_db_instance" "this" {
  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  db_name  = var.db_name
  username = var.username
  password = var.manage_master_user_password ? null : coalesce(var.password, try(random_password.master[0].result, null))
  port     = local.port

  manage_master_user_password = var.manage_master_user_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az

  backup_retention_period   = var.backup_retention_period
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final"
  apply_immediately         = var.apply_immediately

  performance_insights_enabled = var.performance_insights_enabled

  tags = merge(local.common_tags, { Name = var.identifier })
}
