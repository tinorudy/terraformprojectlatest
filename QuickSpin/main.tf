provider "aws" {
  profile = "default"
  region = "eu-west-1"
}



resource "aws_vpc" "main" {
  cidr_block           = "192.167.0.0/23"
  instance_tenancy     = "dedicated"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "fife"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.167.0.0/28"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true

  

}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name        = "RTB"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_security_group" "allow-access" {
  name        = "SG1"
  description = "Allow inbound traffic access"
  vpc_id      = aws_vpc.main.id

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

resource "aws_launch_template" "main" {
  name          = "Version1"
  image_id         = "ami-0ffea00000f287d30"
  instance_type    = "t2.micro"
  key_name         = "Tinorudy"
  #instance_initiated_shutdown_behavior = "terminate"
  vpc_security_group_ids = [aws_security_group.allow-access.id]
  update_default_version = true
  
}

resource "aws_autoscaling_group" "asg" {
  name                         = "asg"
  vpc_zone_identifier          = [aws_subnet.public.id]
  #availability_zones = [eu-west-1a]
  max_size                     = 2
  min_size                     = 1
  health_check_grace_period    = 300
  force_delete                 = true
  desired_capacity             = 1

  launch_template {
    id =   aws_launch_template.main.id
    version = "$Latest"
  }
}


