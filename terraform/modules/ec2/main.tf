# ============================================================================
# EC2 MODULE — generic instance + security group.
# Ingress rules are passed in as a list. Used for the SonarQube host:
#   SSH(22) from admin IP, SonarQube(9000) from anywhere.
# ============================================================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "${var.name} security group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-sg" }
}

resource "aws_instance" "this" {
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = var.associate_public_ip
  user_data                   = var.user_data
  iam_instance_profile        = var.enable_ssm ? aws_iam_instance_profile.this[0].name : null

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = { Name = var.name }

  lifecycle {
    # Canonical publishes new Ubuntu AMIs constantly; without this, most_recent
    # would force a replace on every plan. Ignore AMI/user_data drift so the
    # instance is stable once created.
    ignore_changes = [ami, user_data]
  }
}

# Optional Elastic IP for a stable public address (SonarQube).
resource "aws_eip" "this" {
  count    = var.associate_eip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.this.id
  tags     = { Name = "${var.name}-eip" }
}

# ---------------------------------------------------------------------------
# SSM (Session Manager) — connect with no SSH port / no IP whitelist.
# Ubuntu AMIs ship the ssm-agent preinstalled; it registers once the instance
# has this role and outbound internet (public subnet + IGW already provide it).
# ---------------------------------------------------------------------------
resource "aws_iam_role" "ssm" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.name}-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.name}-instance-profile"
  role  = aws_iam_role.ssm[0].name
}