variable "region" {
  description = "Region to use"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to use"
  type        = string
}

variable "bastion" {
  description = "Bastion parameters"
  type = object({
    enable        = bool
    vpc_subnet    = string
    ami           = string
    instance_type = string 
    whitelist_ips = list(string)
  })
}

variable "mgmt_pool" {
  description = "Management node pool parameters"
  type = object({
    azs                 = list(string) # Availability zones to use
    vpc_subnets         = list(string) # Subnets to use
    nodes_ami           = string       # AMI for mgmt nodes
    nodes_instance_type = string       # EC2 instance type
    nodes_count         = number       # Number of mgmt nodes
  })
}

variable "storage_pools" {
  description = "Map of storage pools parameters"
  type = map(object({
    azs                 = list(string) # Availability zones to use
    vpc_subnets         = list(string) # Subnets to use. Should match AZs
    nodes_ami           = string       # Storage nodes AMI
    nodes_instance_type = string       # Storage nodes type
    nodes_count         = number       # Storage nodes count
    s3_bucket_names     = list(string) # S3 bucket names to store block data
    s3_force_destroy    = bool         # Whether to force destroy the S3 bucket (delete even if it contains objects)
  }))
}

