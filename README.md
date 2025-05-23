# Storage Infrastructure with Bastion and S3 Access

This Terraform configuration sets up a secure and scalable infrastructure in AWS including:

- A Bastion EC2 instance to access private nodes
- Storage EC2 instances with IAM roles to access an S3 bucket
- Security groups for controlled access
- An S3 bucket for storage
- SSH access with a shared key pair

## 🔧 Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS credentials with permission to create EC2, IAM, VPC, and S3 resources
- SSH key pair (`~/.ssh/id_rsa.pub`) available locally

## 📁 File Structure



```bash
aws/
├── main.tf              # Core infrastructure definitions
├── provider.tf          # AWS provider setup
├── variables.tf         # Input variables
├── outputs.tf           # Output definitions

```

## 🚀 Usage

1. Initialize Terraform

```
terraform init
```

2. Set variables

Copy and customize terraform.tfvars:

```
    bastion_ami              = "ami-0abcdef1234567890"
    bastion_instance_type    = "t3.micro"
    storage_nodes_ami        = "ami-0abcdef1234567890"
    storage_nodes_instance_type = "t3.small"
    storage_nodes_count      = 3
    storage_s3_bucket_name   = "my-storage-bucket"
    storage_s3_force_destroy = true
    vpc_id                   = "vpc-xxxxxxxx"
    vpc_subnets              = ["subnet-xxxx", "subnet-yyyy"]
    azs                      = ["us-east-1a", "us-east-1b"]
    bastion_whitelist_ips    = ["YOUR.IP.ADDRESS/32"]
```

3. Apply the configuration

```
terraform apply
```

4. Get bastion IP

Terraform will output the public IP of the Bastion host:

bastion_public_ip = "X.X.X.X"

5. SSH into bastion

```
ssh -i ~/.ssh/id_rsa ubuntu@<bastion_public_ip>
```

6. SSH into storage nodes from bastion

Get private IPs from outputs:

```
terraform output storage_node_private_ips
```

Then SSH from bastion:

```
ssh -i ~/.ssh/id_rsa ubuntu@<storage_node_private_ip>
```
