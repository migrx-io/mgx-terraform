
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_iam_role" "storage_s3_full_access" {
  name = "storage-${var.storage_s3_bucket_name}-full-access-role"

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

resource "aws_iam_role_policy" "s3_bucket_only" {
  name = "bucket-${var.storage_s3_bucket_name}-access-policy"
  role = aws_iam_role.storage_s3_full_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.storage_s3_bucket_name}",
          "arn:aws:s3:::${var.storage_s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-${var.storage_s3_bucket_name}-instance-profile"
  role = aws_iam_role.storage_s3_full_access.name
}


resource "aws_security_group" "bastion_sg" {
  name        = "storage-bastion-sg"
  description = "Bastion security group"

  vpc_id = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_whitelist_ips
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_vpc_internal" {
  name        = "allow_vpc_internal"
  description = "Allow all traffic from the same VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all inbound traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  subnet_id                   = var.vpc_subnets[0]
  associate_public_ip_address = true
  root_block_device {
    volume_size = 15
  }
  tags = {
    Name = "storage-bastion"
    Service = "mgx-storage"
  }
}


resource "aws_instance" "storage_node" {
  count             = var.storage_nodes_count
  availability_zone = element(var.azs, count.index % length(var.azs))
  ami               = var.storage_nodes_ami
  instance_type     = var.storage_nodes_instance_type

  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_vpc_internal.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = element(var.vpc_subnets, count.index % length(var.vpc_subnets))

  tags = {
    Name = "storage-node-${var.storage_s3_bucket_name}-${count.index}"
    Service = "mgx-storage"
  }
}

resource "aws_s3_bucket" "s3storage" {
  bucket        = var.storage_s3_bucket_name
  force_destroy = var.storage_s3_force_destroy

  tags = {
    Service = "mgx-storage"
  }

}
