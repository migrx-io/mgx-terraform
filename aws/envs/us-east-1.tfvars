region = "us-east-1"

vpc_id = "vpc-095dc0635c6244fe3"

azs = ["us-east-1a", 
       "us-east-1b", 
       "us-east-1c"]

mgmt_subnet_cidrs = [
  "172.31.96.0/20",  # us-east-1a primary
  "172.31.112.0/20",  # us-east-1b primary
  "172.31.128.0/20"   # us-east-1c primary
]

storage_subnet_cidrs = [
  "172.31.144.0/20",   # us-east-1a secondary
  "172.31.160.0/20",  # us-east-1b secondary
  "172.31.176.0/20"   # us-east-1c secondary
]

bastion = {
    enable        = true
    vpc_subnet    = "subnet-06b5191fc3bf0caff"
    ami           = "ami-0f9de6e2d2f067fca"
    instance_type = "t2.micro"
    whitelist_ips = ["0.0.0.0/0"]
}

mgmt_pool = {
    nodes_ami           = "ami-0f9de6e2d2f067fca"
    nodes_instance_type = "t3a.xlarge"
    nodes_count         = 7
}

storage_pools = {
  pool1 = {
    nodes_ami           = "ami-0f9de6e2d2f067fca"
    nodes_instance_type = "c5ad.2xlarge"
    nodes_count         = 3
    s3_bucket_names     = ["mgxs3storage1"]
    s3_force_destroy    = true
  }
  pool2 = {
    nodes_ami           = "ami-0f9de6e2d2f067fca"
    nodes_instance_type = "c5ad.2xlarge"
    nodes_count         = 8
    s3_bucket_names     = []
    s3_force_destroy    = true
  }
  pool3 = {
    nodes_ami           = "ami-0f9de6e2d2f067fca"
    nodes_instance_type = "c5ad.2xlarge"
    nodes_count         = 3
    s3_bucket_names     = []
    s3_force_destroy    = true
  }



}
