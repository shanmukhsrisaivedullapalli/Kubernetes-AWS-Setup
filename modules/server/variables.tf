variable "server_name" {
    description = "Name of the server"
    type        = string
}

variable "instance_type" {
    description = "Type of the instance"
    type        = string
    default     = "c7i-flex.large"
}

variable "tags" {
    description = "Additional tags for the server"
    type        = map(string)
}

variable "key_name" {
    description = "Name of the key pair to use for the instance"
    type        = string
    default     = "MyPersonalFavoriteKeyPair"
}

variable "associate_public_ip_address" {
    description = "Whether to associate a public IP address with the instance"
    type        = bool
    default     = true
}

variable "vpc_security_group_ids" {
    description = "List of security groups to associate with the instance"
    type        = list(string)
}

variable "subnet_id" {
    description = "Subnet ID in the VPC"
    type = string
    default = null
}

variable "ami_id" {
    description = "AMI ID"
    type = string
    default = "ami-040f52d90f7218c06"
}

variable "user_data" {
    description = "User defined script to run after spawning EC2 instance"
    type = string
    default = null
}