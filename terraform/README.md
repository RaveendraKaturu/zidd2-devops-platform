# ZIDD 2.0 — Terraform

Module-per-concern layout with a flat root (HRMS-style).

```
terraform/
  .gitignore
  versions.tf              # terraform settings + backend block + providers
  variables.tf
  main.tf                  # all module wiring (foundation + eks + edge + dns)
  lb-controller.tf         # AWS Load Balancer Controller + metrics-server (Helm)
  outputs.tf
  terraform.tfvars.example
  README.md
  bootstrap/               # remote state: S3 bucket + DynamoDB lock (run FIRST)
  modules/
    vpc/                   # 3 public + 3 private subnets, IGW, NAT, RTs, flow logs -> S3
    s3/                    # hardened bucket (VPC flow logs)
    ec2/                   # generic instance + SG (SonarQube)
    ecr/                   # 3 repositories
    iam/                   # GitHub Actions OIDC provider + CI deploy role
    acm/                   # DNS-validated cert (us-east-1 for CloudFront)
    alb/                   # internet-facing ALB, CloudFront-only, target-type ip
    cloudfront/            # CloudFront distribution + WAFv2
    eks/                   # cluster, node group, OIDC/IRSA, add-ons
    secrets-manager/       # app secrets (mysql, jwt)
```

## Deploy order

    # 0. Backend (local state) — creates the tfstate bucket + lock table
    cd bootstrap
    terraform init
    terraform apply -var="region=ap-south-1"
    #    then uncomment the backend "s3" block in ../versions.tf with the
    #    printed bucket + table names

    # 1. Everything else
    cd ..
    cp terraform.tfvars.example terraform.tfvars    # set domain_name, region, etc.
    terraform init -migrate-state
    terraform plan  -out=tfplan
    terraform apply tfplan
    #    if manage_godaddy_dns = false, add the ACM CNAMEs from the outputs at
    #    GoDaddy, then re-run apply so CloudFront picks up the issued cert

    # 2. kubectl
    aws eks update-kubeconfig --name zidd2 --region ap-south-1

## Region / AZ note
Set `region = "ap-south-1"` (Mumbai). ap-south-1a/1b/1c are Availability Zones
inside it — the VPC module spreads the 3+3 subnets across the first three AZs
automatically for multi-AZ resilience. Do not pin to a single AZ.

## Key outputs
- `ecr_repository_urls`         -> CI pushes images here
- `eks_kubeconfig_command`      -> configure kubectl
- `frontend_target_group_arn`   -> Helm values (TargetGroupBinding)
- `cloudfront_domain_name`      -> GoDaddy CNAME target
- `acm_validation_records`      -> GoDaddy CNAMEs (if not automating DNS)
- `github_actions_role_arn`     -> GitHub Actions AWS_ROLE_ARN secret
- `sonarqube_url`               -> http://<ip>:9000 (admin/admin first login)

## Notes
- EKS creates its own cluster/node/IRSA roles; the `iam` module is for the
  GitHub Actions OIDC + CI deploy role.
- `alb` is its own module (EKS ingress target); `waf` lives in the `cloudfront`
  module since it attaches to the distribution.
- WAF IP block/allow lists belong in code (aws_wafv2_ip_set), not the console —
  a later `apply` reverts manual console edits.
- App workloads, Prometheus/Grafana, and ArgoCD are NOT here — see helm/ + cicd/.
