# ============================================================================
# Terraform settings, remote-state backend, and providers.
# ============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    random     = { source = "hashicorp/random", version = "~> 3.5" }
    tls        = { source = "hashicorp/tls", version = "~> 4.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.30" }
    helm       = { source = "hashicorp/helm", version = "~> 2.13" }
    godaddy    = { source = "n3integration/godaddy", version = "~> 1.9" }
  }

  # Remote state. Fill in the bucket + table printed by `bootstrap`, then run
  # `terraform init -migrate-state`. Left commented so the first init works
  # before the bucket exists.
  #
  # backend "s3" {
  #   bucket         = "zidd2-tfstate-xxxxxx"
  #   key            = "infra/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "zidd2-tf-lock"
  #   encrypt        = true
  # }
}

# --- Primary region (VPC, EKS, ECR, EC2, ALB) ---
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = "zidd2"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# --- us-east-1 (CloudFront ACM cert + WAFv2 CLOUDFRONT scope) ---
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      Project     = "zidd2"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# --- Kubernetes / Helm: authenticate to EKS via aws eks get-token ---
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}

# --- GoDaddy (only used when manage_godaddy_dns = true) ---
provider "godaddy" {
  key    = var.godaddy_api_key
  secret = var.godaddy_api_secret
}
