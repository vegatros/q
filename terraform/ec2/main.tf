# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }
# 
# provider "aws" {
#   region = var.aws_region
# }
# 
# # VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}
# 
# # Internet Gateway
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id
# 
#   tags = {
#     Name = "${var.project_name}-igw"
#   }
# }
# 
# # Public Subnets
# resource "aws_subnet" "public" {
#   count                   = 2
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = true
# 
#   tags = {
#     Name = "${var.project_name}-public-${count.index + 1}"
#   }
# }
# 
# # Private Subnets
# resource "aws_subnet" "private" {
#   count             = 2
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
#   availability_zone = data.aws_availability_zones.available.names[count.index]
# 
#   tags = {
#     Name = "${var.project_name}-private-${count.index + 1}"
#   }
# }
# 
# # Public Route Table
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id
# 
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
# 
#   tags = {
#     Name = "${var.project_name}-public-rt"
#   }
# }
# 
# # Public Route Table Association
# resource "aws_route_table_association" "public" {
#   count          = 2
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }
# 
# # Security Group for EC2
# resource "aws_security_group" "ec2" {
#   name        = "${var.project_name}-ec2-sg"
#   description = "Security group for EC2 instances"
#   vpc_id      = aws_vpc.main.id
# 
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# 
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# 
#   tags = {
#     Name = "${var.project_name}-ec2-sg"
#   }
# }
# 
# # EC2 Instances
# resource "aws_instance" "app" {
#   count                  = 2
#   ami                    = data.aws_ami.amazon_linux.id
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.private[count.index].id
#   vpc_security_group_ids = [aws_security_group.ec2.id]
# 
#   user_data = <<-EOF
#               #!/bin/bash
#               yum update -y
#               yum install -y httpd
#               systemctl start httpd
#               systemctl enable httpd
#               echo "<h1>Server ${count.index + 1}</h1>" > /var/www/html/index.html
#               EOF
# 
#   tags = {
#     Name = "${var.project_name}-ec2-${count.index + 1}"
#   }
# }
# 
# 
# 
# # Data Sources
# data "aws_availability_zones" "available" {
#   state = "available"
# }
# 
# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]
# 
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }
