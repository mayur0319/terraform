provider "aws" {
  region = var.aws_region
}

#VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "my-vpc"
  }
}

#Subnet
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1d"

  tags = {
    Name = "my_subnet"
  }
}

#SG
resource "aws_security_group" "vpc_security_group" {
  name_prefix = "my-security-group"
  description = "My security group"

  ingress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.my_vpc.id
}

#IG
resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-internet-gateway"
  }
}

#RT
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gateway.id
  }

  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_instance" "example_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  security_groups        = [aws_security_group.elb_sg.id]
  vpc_security_group_ids = [aws_security_group.vpc_security_group.id]
  subnet_id              = aws_subnet.subnet.id

  tags = {
    Name = "assingment-2-instance"
  }
}

#Create SG for elb
resource "aws_security_group" "elb_sg" {
  name_prefix = "example-elb-sg"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "elb_SB" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "rds_subnet1"
  }
}
