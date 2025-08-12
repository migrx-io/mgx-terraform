# Storage Infrastructure with Bastion and S3 Access

This Terraform configuration sets up a secure and scalable infrastructure in AWS including:

- (Optional) Bastion EC2 instance for SSH access
- Storage EC2 instances across availability zones with IAM roles for S3 access
- Security groups for controlled access
- S3 buckets for object storage (1+ per pool)
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
├── outputs.tf           # Output values
├── envs/
│   └── us-east-1.tfvars # Example environment variables

```

## 🚀 Usage

1. Go to `aws` dir

    ```
    cd ./aws
    ```

2. Initialize Terraform

    ```
    terraform init
    ```

3. Set your variables

    *Bastion resources are only created when bastion_enable = true.*

    *You can define multiple storage_pools with independent configuration.*

    *All storage instances are granted S3 access via IAM roles.*

    Edit or create a `.tfvars` file inside `envs/`. Example: `envs/us-east-1.tfvars`

    ```

    region = "us-east-1"

    vpc_id = "vpc-095dc0635c6244fe3"

    azs = ["us-east-1a", 
           "us-east-1b", 
           "us-east-1c"]

    mgmt_subnet_cidrs = [
        "172.31.96.0/20",  # us-east-1a primary
        "172.31.97.0/20",  # us-east-1b primary
        "172.31.98.0/20"   # us-east-1c primary
    ]

    storage_subnet_cidrs = [
        "172.31.99.0/20",   # us-east-1a secondary
        "172.31.100.0/20",  # us-east-1b secondary
        "172.31.101.0/20"   # us-east-1c secondary
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
        nodes_count         = 1
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
            nodes_count         = 0
            s3_bucket_names     = ["mgxs3storage2"]
            s3_force_destroy    = true
        }
    }

    ```

4. Apply the configuration

    ```
    terraform apply -var-file=./envs/us-east-1.tfvars
    ```

5. Get bastion IP and SSH into bastion

    Get public IPs from outputs:

    ```
    terraform output bastion_public_ip
    ```

    ```
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa


    ssh -A ubuntu@<bastion_public_ip>
    ```

6. SSH into storage nodes from bastion (SSH Agent Forwarding)

    Get private IPs from outputs:

    ```
    terraform output storage_node_mgmt_private_ips
    ```

    Then SSH from bastion:

    ```
    ssh -A ubuntu@<storage_node_private_ip>
    ```
