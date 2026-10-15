resource "aws_instance" "server" {
    ami           = var.ami_id
    instance_type = var.instance_type
    key_name      = var.key_name
    associate_public_ip_address = var.associate_public_ip_address
    vpc_security_group_ids = var.vpc_security_group_ids
    subnet_id = var.subnet_id

    tags = merge({
        Name = var.server_name
    },var.tags)

    user_data = var.user_data
}