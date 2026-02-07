terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "ap-northeast-1"
}

data "aws_subnet" "selected" {
  id = "subnet-0597b0f1a88c5cf13"
}

# Ubuntu 24.04 LTS (x86_64) の最新AMIを取得
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Ubuntu公式のAWSアカウントID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# セキュリティグループ
resource "aws_security_group" "default" {
  name_prefix = "e2e-playwright-instance-"
  vpc_id      = data.aws_subnet.selected.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "e2e-playwright-instance-sg"
  }
}

# SSM 用 IAM ロール/Instance Profile
resource "aws_iam_role" "ssm" {
  name_prefix = "e2e-playwright-ssm-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name_prefix = "e2e-playwright-ssm-"
  role        = aws_iam_role.ssm.name
}

resource "aws_instance" "default" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = data.aws_subnet.selected.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.default.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name

  tags = {
    Name      = "e2e-playwright-instance"
    ManagedBy = "Terraform"
  }

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    # TOKENを代入する
    REGISTRATION_TOKEN = "BERLJWG5THYG36M64WYGRKLJQ3CVM"
    REGISTRATION_TOKEN_2  = "BERLJWB7JMCBOSPMPT5SSJLJQ3CXG"
  })
}

