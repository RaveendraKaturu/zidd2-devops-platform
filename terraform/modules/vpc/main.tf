# ============================================================================
# VPC MODULE
#  - 1 VPC
#  - 3 public subnets  (one per AZ)  -> Internet Gateway
#  - 3 private subnets (one per AZ)  -> NAT Gateway(s)
#  - VPC Flow Logs -> S3 (bucket created in bootstrap)
# ============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  # /16 VPC split into /20 subnets. 6 subnets used (3 public + 3 private).
  public_cidrs  = [for i in range(3) : cidrsubnet(var.vpc_cidr, 4, i)]     # .0 .16 .32
  private_cidrs = [for i in range(3) : cidrsubnet(var.vpc_cidr, 4, i + 3)] # .48 .64 .80
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}

# --- Public subnets ---
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${var.name}-public-${local.azs[count.index]}"
    Tier                     = "public"
    "kubernetes.io/role/elb" = "1" # harmless; helps if you ever move to EKS
  }
}

# --- Private subnets ---
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_cidrs[count.index]
  availability_zone = local.azs[count.index]
  tags = {
    Name                              = "${var.name}-private-${local.azs[count.index]}"
    Tier                              = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# --- NAT Gateways ---
# single_nat_gateway=true  -> 1 NAT (cheaper, single AZ risk)
# single_nat_gateway=false -> 1 NAT per AZ (HA, ~3x cost)
locals {
  nat_count = var.single_nat_gateway ? 1 : 3
}

resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"
  tags   = { Name = "${var.name}-nat-eip-${count.index}" }
}

resource "aws_nat_gateway" "this" {
  count         = local.nat_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = { Name = "${var.name}-nat-${count.index}" }
  depends_on    = [aws_internet_gateway.this]
}

# --- Public route table (shared by all public subnets) ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- Private route tables (one per AZ so each can use its AZ's NAT) ---
resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-private-rt-${local.azs[count.index]}" }
}

resource "aws_route" "private_nat" {
  count                  = 3
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ---------------------------------------------------------------------------
# VPC Flow Logs -> S3
# ---------------------------------------------------------------------------
resource "aws_flow_log" "s3" {
  log_destination      = var.flow_logs_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id

  destination_options {
    file_format        = "parquet"
    per_hour_partition = true
  }

  tags = { Name = "${var.name}-flow-logs" }
}
