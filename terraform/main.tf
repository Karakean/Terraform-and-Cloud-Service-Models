# 0. Initial setup

terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "demo_private_subnet" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "zsch-private-subnet"
  }
}

# 1. IaaS

resource "aws_network_interface" "demo_eni" {
  subnet_id = aws_subnet.demo_private_subnet.id
  count = 2

  tags = {
    Name = "zsch-primary-eni-${count.index}"
  }
}

resource "aws_instance" "demo_ec2" {
  ami = "ami-00cf59bc9978eb266"
  instance_type = "t2.micro"
  count = 2

  network_interface {
    network_interface_id = aws_network_interface.demo_eni[count.index].id
    device_index = 0
  }

  tags = {
    Name = "zsch-ec2-${count.index}"
  }
}

# 2. PaaS (& CaaS)

# 3. SaaS