locals {
  tags = {
    prefix = "${var.prefix}-${var.environment}"
  }

  web_instance_count     = var.public_subnets
  backend_instance_count = var.private_subnets
}