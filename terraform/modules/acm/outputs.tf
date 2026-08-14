output "certificate_arn" {
  value = var.wait_for_validation ? aws_acm_certificate_validation.this[0].certificate_arn : aws_acm_certificate.this.arn
}
output "validation_records" {
  description = "Add these CNAMEs at your DNS provider"
  value = [for o in aws_acm_certificate.this.domain_validation_options : {
    name  = o.resource_record_name
    type  = o.resource_record_type
    value = o.resource_record_value
  }]
}
