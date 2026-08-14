# ============================================================================
# ACM MODULE — DNS-validated certificate.
# For CloudFront the cert MUST be in us-east-1, so the caller passes the
# us-east-1 provider in as the module's default aws provider.
# Validation records are OUTPUT for you to add at GoDaddy (or created
# automatically by the GoDaddy provider in the root when manage_dns = true).
# ============================================================================

terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "this" {
  count                   = var.wait_for_validation ? 1 : 0
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for o in aws_acm_certificate.this.domain_validation_options : o.resource_record_name]
}
