output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }

output "flow_logs_bucket" { value = module.s3_flow_logs.bucket_id }
output "ecr_repository_urls" { value = module.ecr.repository_urls }

output "sonarqube_url" { value = "http://${module.sonarqube.public_ip}:9000" }
output "sonarqube_public_ip" { value = module.sonarqube.public_ip }

output "eks_cluster_name" { value = module.eks.cluster_name }
output "eks_kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

output "alb_dns_name" { value = module.alb.alb_dns_name }
output "frontend_target_group_arn" {
  description = "Set this as targetGroupARN in the Helm values (TargetGroupBinding)"
  value       = module.alb.target_group_arn
}
output "cloudfront_domain_name" {
  description = "Create a GoDaddy CNAME: your app host -> this"
  value       = module.cloudfront.domain_name
}
output "acm_validation_records" {
  description = "Add these CNAMEs at GoDaddy if not automating DNS"
  value       = module.acm.validation_records
}

output "github_actions_role_arn" {
  description = "Set as AWS_ROLE_ARN secret in GitHub Actions"
  value       = module.iam.ci_role_arn
}
output "secret_arns" { value = module.secrets.secret_arns }


