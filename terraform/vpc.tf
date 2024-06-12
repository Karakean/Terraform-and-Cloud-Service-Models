resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "zsch-vpc"
  }
}

resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id
}

resource "aws_route_table" "demo_route_table" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }
}

resource "aws_route_table_association" "demo_route_table_association_1a" {
  subnet_id      = aws_subnet.demo_subnet_1a.id
  route_table_id = aws_route_table.demo_route_table.id
}

resource "aws_route_table_association" "demo_route_table_association_1b" {
  subnet_id      = aws_subnet.demo_subnet_1b.id
  route_table_id = aws_route_table.demo_route_table.id
}

resource "aws_subnet" "demo_subnet_1a" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "zsch-subnet-1a"
  }
}

resource "aws_subnet" "demo_subnet_1b" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "zsch-subnet-1b"
  }
}