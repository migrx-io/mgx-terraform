variable "region" {
  description = "Region to use"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to use"
  type        = string
}

variable "azs" {
  description = "Availability zones to use"
  type        = list(string)
}

variable "vpc_subnets" {
  description = "Subnets to use. Should match AZs"
  type        = list(string)
}

variable "storage_pool_name" {
  description = "Storage pool name"
  type        = string
}

variable "storage_nodes_ami" {
  description = "Storage nodes AMI"
  type        = string
}

variable "storage_nodes_instance_type" {
  description = "Storage nodes type"
  type        = string
}

variable "storage_nodes_count" {
  description = "Storage nodes count"
  type        = number
}

variable "storage_s3_bucket_names" {
  description = "S3 bucket names to store block data"
  type        = list(string)
}

variable "storage_s3_force_destroy" {
  description = "Whether to force destroy the S3 bucket (delete even if it contains objects)"
  type        = bool
  default     = false
}

variable "bastion_ami" {
  description = "Bastion AMI"
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
