# ============================================================================
# ZIDD 2.0 — root wiring
#   Foundation : vpc | s3(flow logs) | ecr | secrets | iam(github oidc) | ec2(sonar)
#   Cluster    : eks         (controllers -> lb-controller.tf)
#   Edge       : acm | alb | cloudfront | godaddy dns
# ============================================================================

# ---------------------------------------------------------------------------
# S3 — VPC flow-logs bucket (the tfstate bucket lives in bootstrap/)
# ---------------------------------------------------------------------------
module "s3_flow_logs" {
  source           = "./modules/s3"
  name             = "${var.name}-vpc-flow-logs"
  expiration_days  = 90
  flow_logs_policy = true
  force_destroy    = true
}

# ---------------------------------------------------------------------------
# VPC — 3 public + 3 private subnets, NAT, flow logs -> S3
# ---------------------------------------------------------------------------
module "vpc" {
  source               = "./modules/vpc"
  name                 = var.name
  vpc_cidr             = var.vpc_cidr
  single_nat_gateway   = var.single_nat_gateway
  flow_logs_bucket_arn = module.s3_flow_logs.bucket_arn
}

# ---------------------------------------------------------------------------
# ECR — 3 repositories
# ---------------------------------------------------------------------------
module "ecr" {
  source           = "./modules/ecr"
  repository_names = var.ecr_repositories
}

# ---------------------------------------------------------------------------
# Secrets Manager — app secrets (mysql, jwt)
# ---------------------------------------------------------------------------
module "secrets" {
  source = "./modules/secrets-manager"
  name   = var.name
  secrets = {
    mysql = {
      username = "root"
      password = var.mysql_root_password
      database = "spring_auth_api"
    }
    auth = {
      jwt_secret_key = var.jwt_secret_key
    }
  }
}

# ---------------------------------------------------------------------------
# IAM — GitHub Actions OIDC provider + CI deploy role
# ---------------------------------------------------------------------------
module "iam" {
  source               = "./modules/iam"
  name                 = var.name
  github_org           = var.github_org
  github_repo          = var.github_repo
  ecr_repository_arns  = values(module.ecr.repository_arns)
  create_oidc_provider = var.create_github_oidc_provider
}

# ---------------------------------------------------------------------------
# EC2 — SonarQube
# ---------------------------------------------------------------------------
locals {
  sonar_user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail
    sysctl -w vm.max_map_count=262144
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    echo "fs.file-max=131072" >> /etc/sysctl.conf
    sysctl -p
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    systemctl enable --now docker
    docker volume create sonarqube_data
    docker volume create sonarqube_extensions
    docker volume create sonarqube_logs
    docker run -d --name sonarqube --restart unless-stopped \
      -p 9000:9000 \
      -v sonarqube_data:/opt/sonarqube/data \
      -v sonarqube_extensions:/opt/sonarqube/extensions \
      -v sonarqube_logs:/opt/sonarqube/logs \
      sonarqube:community
  EOF
}

module "sonarqube" {
  source              = "./modules/ec2"
  name                = "${var.name}-sonarqube"
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnet_ids[0]
  instance_type       = var.sonar_instance_type
  key_name            = var.sonar_key_name
  associate_public_ip = true
  associate_eip       = true
  enable_ssm          = true
  volume_size         = 30
  user_data           = local.sonar_user_data
  ingress_rules = [
    {
      description = "SSH from admin IP"
      port        = 22
      cidr_blocks = ["${var.sonar_ssh_ip}/32"]
    },
    {
      description = "SonarQube UI/API"
      port        = 9000
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# ---------------------------------------------------------------------------
# EKS — cluster + node group + OIDC/IRSA + add-ons
# (AWS Load Balancer Controller + metrics-server -> lb-controller.tf)
# ---------------------------------------------------------------------------
module "eks" {
  source                = "./modules/eks"
  name                  = var.name
  k8s_version           = var.k8s_version
  private_subnet_ids    = module.vpc.private_subnet_ids
  public_subnet_ids     = module.vpc.public_subnet_ids
  node_instance_types   = var.node_instance_types
  node_desired_size     = var.node_desired_size
  node_min_size         = var.node_min_size
  node_max_size         = var.node_max_size
  alb_security_group_id = module.alb.security_group_id
}

# ---------------------------------------------------------------------------
# ACM — CloudFront cert (us-east-1)
# ---------------------------------------------------------------------------
module "acm" {
  source = "./modules/acm"
  providers = {
    aws = aws.us_east_1
  }
  domain_name         = var.domain_name
  wait_for_validation = var.manage_godaddy_dns
}

# ---------------------------------------------------------------------------
# ALB — EKS ingress target, reachable only from CloudFront
# ---------------------------------------------------------------------------
module "alb" {
  source            = "./modules/alb"
  name              = var.name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  health_check_path = "/"
}

# ---------------------------------------------------------------------------
# CloudFront + WAF (us-east-1 for the WAF scope)
# ---------------------------------------------------------------------------
module "cloudfront" {
  source = "./modules/cloudfront"
  providers = {
    aws = aws.us_east_1
  }
  name               = var.name
  domain_name        = var.domain_name
  origin_domain_name = module.alb.alb_dns_name
  certificate_arn    = module.acm.certificate_arn
}

# ---------------------------------------------------------------------------
# GoDaddy DNS (optional — manage_godaddy_dns = true + API creds).
# The provider manages the domain's record set as one resource, so the ACM
# validation CNAME(s) and the app CNAME are combined here. If GoDaddy's API
# isn't available on your plan, leave this off and add the records printed by
# `terraform output` by hand.
# ---------------------------------------------------------------------------
locals {
  domain_parts = split(".", var.domain_name)
  apex_domain  = join(".", slice(local.domain_parts, length(local.domain_parts) - 2, length(local.domain_parts)))
  app_host     = length(local.domain_parts) > 2 ? join(".", slice(local.domain_parts, 0, length(local.domain_parts) - 2)) : "@"

  godaddy_validation_records = [
    for r in module.acm.validation_records : {
      name = trimsuffix(trimsuffix(r.name, "."), ".${local.apex_domain}")
      data = trimsuffix(r.value, ".")
    }
  ]
}

resource "godaddy_domain_record" "this" {
  count  = var.manage_godaddy_dns ? 1 : 0
  domain = local.apex_domain

  dynamic "record" {
    for_each = local.godaddy_validation_records
    content {
      name = record.value.name
      type = "CNAME"
      data = record.value.data
      ttl  = 600
    }
  }

  record {
    name = local.app_host
    type = "CNAME"
    data = module.cloudfront.domain_name
    ttl  = 600
  }
}

# Let the GitHub Actions role run kubectl/helm against the cluster
resource "aws_eks_access_entry" "github_ci" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.iam.ci_role_arn
  type          = "STANDARD"
}
resource "aws_eks_access_policy_association" "github_ci" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.iam.ci_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}
