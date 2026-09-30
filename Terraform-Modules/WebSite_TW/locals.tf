locals {
  common_tags = {
    Company     = var.company_name
    Environment = var.environment
  }
  naming_prefix = "${var.company_name}-${var.environment}"
}