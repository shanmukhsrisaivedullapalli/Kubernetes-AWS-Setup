terraform {
    required_version = ">= 1.5.0"

    backend "s3" {
        bucket         = "my-k8s-tf-state-bucket"
        key            = "k8s-cluster/terraform.tfstate"
        region         = "ap-south-2"
        dynamodb_table = "tf-state-lock"
        encrypt        = true
        skip_region_validation = true
    }

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}

provider "aws" {
    region = "ap-south-2"
}

variable "vpc_id" {
    description = "The ID of the VPC"
    type        = string
    default     = "vpc-0f2642ee73ba023f3"
}

module "k8s_security_group" {
    source = "./modules/security_group"
    vpc_id = var.vpc_id
}

module "control_plane" {
  source = "./modules/server"
  server_name = "Control Plane"
  vpc_security_group_ids = [module.k8s_security_group.sg_id]
  subnet_id = "subnet-01b4e1bd22456b45f"
  tags = {
    Role = "K8s-Control-Plane"
  }
  user_data = file("${path.module}/control-plane-config.txt")
}

module "worker_node" {
  source = "./modules/server"
  server_name = "Worker Node"
  vpc_security_group_ids = [module.k8s_security_group.sg_id]
  subnet_id = "subnet-01b4e1bd22456b45f"
  tags = {
    Role = "K8s-Worker-Node"
  }
}

output "sg_name" {
  value = module.k8s_security_group.sg_name
}
output "sg_id" {
  value = module.k8s_security_group.sg_id
}

output "K8s_Control_Plane" {
  value = module.control_plane.ip_address
}
output "K8s_Worker_Node" {
  value = module.worker_node.ip_address
}