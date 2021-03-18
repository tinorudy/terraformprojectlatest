resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "fife"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = var.vpc_id
  count =  length(var.public_cidr)
  cidr_block = element(var.public_cidr,count.index)
  availability_zone = element(var.public_az,count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = element(var.public_cidr_name,count.index)
  }

}

resource "aws_subnet" "private" {
  vpc_id     = var.vpc_id
  count =  length(var.private_cidr)
  cidr_block = element(var.private_cidr,count.index)
  availability_zone = element(var.private_az,count.index)

  tags = {
    Name = element(var.private_cidr_name,count.index)
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  tags = {
    Name        = "RTB"
  }
}

resource "aws_route_table_association" "main" {
  count = length(var.public_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.rtb.*.id , count.index)
}

resource "aws_security_group" "allow-access" {
  name        = "SG1"
  description = "Allow inbound traffic access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-access"
  }
}
