# ============================================================================
# BOOTSTRAP  —  run ONCE, with LOCAL state, before the main stack.
# Creates ONLY the remote-state backend:
#   - S3 bucket for terraform state
#   - DynamoDB table for state locking
# (The VPC-flow-logs bucket is created by the main stack's S3 module.)
# ============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.5" }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project   = "zidd2"
      ManagedBy = "terraform"
      Stack     = "bootstrap"
    }
  }
}

variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "project" {
  type    = string
  default = "zidd2"
}

resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.project}-tfstate-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "${var.project}-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

output "tf_state_bucket" { value = aws_s3_bucket.tf_state.id }
output "tf_lock_table" { value = aws_dynamodb_table.tf_lock.name }
output "region" { value = var.region }
