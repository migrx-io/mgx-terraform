region = "us-east-1"

vpc_id = "vpc-095dc0635c6244fe3"

azs = ["us-east-1a"]

mgmt_subnet_cidrs = [
  "172.31.96.0/20",  # us-east-1a primary
]

storage_subnet_cidrs = [
  "172.31.144.0/20", # us-east-1a secondary
]

bastion = {
  enable        = true
  vpc_subnet    = "subnet-06b5191fc3bf0caff"
  ami           = "ami-029f1e8b2d0665554"
  instance_type = "t4g.micro"
  whitelist_ips = ["0.0.0.0/0"]
}

mgmt_pool = {
  nodes_ami           = "ami-029f1e8b2d0665554"
  nodes_instance_type = "t4g.xlarge"
  nodes_count         = 0
}

#
# How to calculate ther rw/r cache size
# Avaliable (Disk size in GiB * 1024) * 0.93 (7% for metadata)
# RW cache = Avaliable * 0.05 
# R cache = (Avaliable) - RW cache * Number of nodes
# 

storage_pools = {
  pool1 = {
    description           = "Test pool1"
    labels                = "name=pool-1,env=dev"
    nodes_ami             = "ami-029f1e8b2d0665554"
    nodes_instance_type   = "m8gb.xlarge"
    nodes_count           = 3
    nvme_node_disks_count = 10 # = sum of ebs_volumes count when raid_level = 0
    max_volumes_count     = 10
    r_cache_size_in_mib   = 90000 # read cache
    rw_cache_size_in_mib  = 10000  # write cache
    raid_level            = 0     # 0 = EBS RAID0 cache built from ebs_volumes
    s3_bucket_names       = ["mgxs3storage1"]
    s3_force_destroy      = true
    enable_metrics        = true
    enable_grafana        = true
    # EBS volumes attached per node and striped into one RAID0 cache.
    ebs_volumes = [
      {
        size       = 100
        type       = "gp3"
        iops       = 3000
        throughput = 125
        count      = 10
      }
    ]
  }
}
