variable "region" {
  description = "Region to use"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to use"
  type        = string
}

variable "storage_pools" {
  description = "Map of storage pools"
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

variable "bastion_ami" {
  description = "Bastion AMI"
  type        = string
}

variable "bastion_vpc_subnet" {
  description = "Bastion vpc subnet"
  type        = string
}

variable "bastion_instance_type" {
  description = "Bastion instance type"
  type        = string
}

variable "bastion_whitelist_ips" {
  description = "Basion whitelist ips"
  type        = list(string)
}
