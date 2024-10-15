resource "aws_elasticache_serverless_cache" "eai_gearpal" {
  engine = "redis"
  name   = "${var.redis_app_name}"
  description              = "${local.application_name}"
  major_engine_version     = "7"
  security_group_ids       = [var.redis_security_group_id]
  subnet_ids               = var.redis_subnet_ids
  }