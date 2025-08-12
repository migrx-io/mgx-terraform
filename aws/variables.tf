variable "region" {
  description = "Region to use"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to use"
  type        = string
}

variable "reserved_ip_count" {
  description = "Number of reserved IPs per pool"
  type        = number
  default     = 10
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "mgmt_subnet_cidrs" {
  description = "CIDRs for management subnets (one per AZ)"
  type        = list(string)
}

variable "storage_subnet_cidrs" {
  description = "CIDRs for storage subnets (one per AZ)"
  type        = list(string)
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

variable "ssh_user" {
  description = "SSH username for EC2 instances"
  type        = string
  default     = "ubuntu" # or ec2-user for Amazon Linux
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key used for EC2 access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "mgmt_pool" {
  description = "Management node pool parameters"
  type = object({
    nodes_ami           = string # AMI for mgmt nodes
    nodes_instance_type = string # EC2 instance type
    nodes_count         = number # Number of mgmt nodes
  })
}

variable "storage_pools" {
  description = "Map of storage pools parameters"
  type = map(object({
    nodes_ami           = string       # Storage nodes AMI
    nodes_instance_type = string       # Storage nodes type
    nodes_count         = number       # Storage nodes count
    s3_bucket_names     = list(string) # S3 bucket names to store block data
    s3_force_destroy    = bool         # Whether to force destroy the S3 bucket (delete even if it contains objects)
  }))

}
