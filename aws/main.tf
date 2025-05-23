
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_iam_role" "storage_s3_full_access" {
  for_each = var.storage_pools

  name = "storage-${each.key}-full-access-role"

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
  for_each = var.storage_pools

  name = "bucket-${each.key}-access-policy"
  role = aws_iam_role.storage_s3_full_access[each.key].id

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
        Resource = concat(
          [for name in var.storage_pools[each.key].s3_bucket_names : "arn:aws:s3:::${name}"],
          [for name in var.storage_pools[each.key].s3_bucket_names : "arn:aws:s3:::${name}/*"]
        )
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  for_each = var.storage_pools

  name = "ec2-s3-${each.key}-instance-profile"
  role = aws_iam_role.storage_s3_full_access[each.key].name
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
  subnet_id                   = var.bastion_vpc_subnet
  associate_public_ip_address = true
  root_block_device {
    volume_size = 15
  }
  tags = {
    Name    = "storage-bastion"
    Service = "mgx-storage"
  }
}

resource "aws_instance" "storage_node" {
  for_each = merge([
    for pool_name, pool in var.storage_pools : {
      for index in range(pool.nodes_count) :
      "${pool_name}-${index}" => {
        pool_name   = pool_name
        pool_config = pool
        index       = index
        az          = pool.azs[index % length(pool.azs)]
        subnet      = pool.vpc_subnets[index % length(pool.vpc_subnets)]
      }
    }
  ]...)

  ami                    = each.value.pool_config.nodes_ami
  instance_type          = each.value.pool_config.nodes_instance_type
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile[each.value.pool_name].name

  subnet_id              = each.value.subnet
  availability_zone      = each.value.az
  vpc_security_group_ids = [aws_security_group.allow_vpc_internal.id]

  tags = {
    Name    = "storage-node-${each.value.pool_name}-${each.value.index}"
    Service = "mgx-storage"
  }
}

resource "aws_s3_bucket" "s3storage" {
  for_each = {
    for pair in flatten([
      for pool_name, pool in var.storage_pools : [
        for bucket_name in pool.s3_bucket_names : {
          key         = "${pool_name}-${bucket_name}"
          bucket_name = bucket_name
          pool_name   = pool_name
          force_destroy = pool.s3_force_destroy
        }
      ]
    ]) : pair.key => {
      bucket_name   = pair.bucket_name
      pool_name     = pair.pool_name
      force_destroy = pair.force_destroy
    }
  }

  bucket        = each.value.bucket_name
  force_destroy = each.value.force_destroy

  tags = {
    Service = "mgx-storage"
    Pool    = each.value.pool_name
  }
}


