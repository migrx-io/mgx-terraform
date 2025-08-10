region = "us-east-1"
vpc_id = "vpc-095dc0635c6244fe3"

bastion = {
    enable        = true
    vpc_subnet    = "subnet-06b5191fc3bf0caff"
    ami           = "ami-0f9de6e2d2f067fca"
    instance_type = "t2.micro"
    whitelist_ips = ["0.0.0.0/0"]
}

mgmt_pool = {
    azs = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c"
    ]
    vpc_subnets = [
      "subnet-06b5191fc3bf0caff", # us-east-1a
      "subnet-03fdfb2126b2c9ef0", # us-east-1b
      "subnet-09762cb2835ed749b"  # us-east-1c
    ]
    nodes_ami           = "ami-0f9de6e2d2f067fca"
    nodes_instance_type = "t3a.xlarge"
    nodes_count         = 3
}

storage_pools = {
  pool1 = {
    azs = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c"
    ]
    vpc_subnets = [
      "subnet-06b5191fc3bf0caff", # us-east-1a
      "subnet-03fdfb2126b2c9ef0", # us-east-1b
      "subnet-09762cb2835ed749b"  # us-east-1c
    ]
    nodes_ami           = "ami-0f9de6e2d2f067fca"
    nodes_instance_type = "c5ad.2xlarge"
    nodes_count         = 3
    s3_bucket_names     = ["mgxs3storage1"]
    s3_force_destroy    = true
  }
  pool2 = {
    azs = [
      "us-east-1b",
      "us-east-1c"
    ]
    vpc_subnets = [
      "subnet-03fdfb2126b2c9ef0", # us-east-1b
      "subnet-09762cb2835ed749b"  # us-east-1c
    ]
    nodes_ami           = "ami-0f9de6e2d2f067fca"
    nodes_instance_type = "c5ad.2xlarge"
    nodes_count         = 3
    s3_bucket_names     = ["mgxs3storage2"]
    s3_force_destroy    = true
  }

}
