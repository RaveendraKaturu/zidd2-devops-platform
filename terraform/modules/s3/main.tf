# ============================================================================
# S3 MODULE — generic hardened bucket.
# Used for the VPC flow-logs bucket (flow_logs_policy = true attaches the
# delivery-service bucket policy). Reusable for other buckets too.
# ============================================================================

resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  bucket_name = "${var.name}-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
  tags          = { Name = local.bucket_name }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.expiration_days > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id
  rule {
    id     = "expire"
    status = "Enabled"
    filter {}
    expiration { days = var.expiration_days }
  }
}

data "aws_caller_identity" "current" {}

# Bucket policy allowing the VPC Flow Logs delivery service to write.
resource "aws_s3_bucket_policy" "flow_logs" {
  count  = var.flow_logs_policy ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSLogDeliveryWrite"
        Effect    = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.this.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" } }
      },
      {
        Sid       = "AWSLogDeliveryAclCheck"
        Effect    = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.this.arn
      }
    ]
  })
}
