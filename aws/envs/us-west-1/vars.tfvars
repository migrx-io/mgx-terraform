region = "us-west-1"

vpc_id = "vpc-03ef2bd78a62d7abc"

azs = ["us-west-1b"]

mgmt_subnet_cidrs = [
  "172.31.96.0/20",  # us-west-1b primary
]

storage_subnet_cidrs = [
  "172.31.144.0/20", # us-west-1b secondary
]

bastion = {
  enable        = true
  vpc_subnet    = "subnet-0506fd08b4bfaa489"
  ami           = "ami-0f9de6e2d2f067fca"
  instance_type = "t2.micro"
  whitelist_ips = ["0.0.0.0/0"]
}

mgmt_pool = {
  nodes_ami           = "ami-0f9de6e2d2f067fca"
  nodes_instance_type = "t3a.xlarge"
  nodes_count         = 1
}

storage_pools = {
  pool1 = {
    description           = "Test pool1"
    labels                = "name=pool-1,env=dev"
    nodes_ami             = "ami-0f9de6e2d2f067fca"
    nodes_instance_type   = "c5ad.2xlarge"
    nodes_count           = 3
    nvme_node_disks_count = 1
    max_volumes_count     = 10
    r_cache_size_in_mib   = 20400
    rw_cache_size_in_mib  = 10480
    raid_level            = 1
    s3_bucket_names       = ["mgxs3storage1"]
    s3_force_destroy      = true
    enable_metrics        = true
    enable_grafana        = true
  }
  pool2 = {
    description           = "Test pool2"
    labels                = "name=pool-2,env=dev"
    nodes_ami             = "ami-0f9de6e2d2f067fca"
    nodes_instance_type   = "c5ad.4xlarge"
    nodes_count           = 0
    nvme_node_disks_count = 0
    max_volumes_count     = 0
    r_cache_size_in_mib   = 0
    rw_cache_size_in_mib  = 0
    raid_level            = 1
    s3_bucket_names       = []
    s3_force_destroy      = true
    enable_metrics        = false
    enable_grafana        = false
  }
}
