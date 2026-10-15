terraform {
    required_version = ">= 1.5.0"

    backend "s3" {
        bucket         = "my-k8s-tf-state-bucket"
        key            = "k8s-cluster/terraform.tfstate"
        region         = "ap-south-2"
        dynamodb_table = "tf-state-lock"
        encrypt        = true
        skip_region_validation = true
        skip_credentials_validation = true
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

resource "aws_vpc" "k8s_vpc" {
  cidr_block = "11.0.0.0/16"
  tags = {
    Name = "k8s-vpc"
  }
}

resource "aws_subnet" "k8s_subnet" {
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = "11.0.1.0/24"
  availability_zone = "ap-south-2a"
  tags = {
    Name = "k8s-subnet"
  }
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "k8s-igw"
  }
}

resource "aws_route_table" "k8s_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "k8s-route-table"
  }
}

resource "aws_route" "k8s_route" {
  route_table_id         = aws_route_table.k8s_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.k8s_igw.id
}

resource "aws_route_table_association" "k8s_route_table_assoc" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_route_table.id
}

resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"
  description = "Security group for Kubernetes cluster"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    description = "Kubernetes API server"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    description = "etcd server client API"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    description = "Kubelet API"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    description = "NodePort Services"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10257
    to_port     = 10259
    protocol    = "tcp"
    description = "Kube Controller Manager and Scheduler"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_key_pair" "MyPersonalFavoriteKeyPair" {
  key_name = "MyPersonalFavoriteKeyPair"
  include_public_key = true
}

resource "aws_instance" "k8s_master" {
  ami           = "ami-03d75ab52ca8481aa"
  instance_type = "c7i-flex.large"
  subnet_id     = aws_subnet.k8s_subnet.id
  key_name      = data.aws_key_pair.MyPersonalFavoriteKeyPair.key_name
  security_groups = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "k8s_worker" {
  ami           = "ami-03d75ab52ca8481aa"
  instance_type = "c7i-flex.large"
  subnet_id     = aws_subnet.k8s_subnet.id
  key_name      = data.aws_key_pair.MyPersonalFavoriteKeyPair.key_name
  security_groups = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "k8s-worker"
  }
}

output "master_public_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_public_ip" {
  value = aws_instance.k8s_worker.public_ip
}