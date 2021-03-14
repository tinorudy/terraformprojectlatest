provider "aws" {
  profile = "default"
  region     = var.region
}

#CREATE VPC DEFINITIONS
resource "aws_vpc" "main" {
  cidr_block           = var.vpc
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "fife"
  }
}

#CREATE PUBLIC SUBNET DEFINITIONS
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  count =  length(var.public_cidr)
  cidr_block = element(var.public_cidr,count.index)
  availability_zone = element(var.public_az,count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = element(var.subnet_name_public,count.index)
  }
}


#CREATE PRIVATE SUBNET-1 DEFINITIONS
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count =  length(var.private_cidr)
  cidr_block = element(var.private_cidr,count.index)
  availability_zone = element(var.private_az,count.index)

  tags = {
    Name = element(var.subnet_name_private,count.index)
  }
}


#CREATE  INTERNET GATEWAY DEFINITIONS
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
  }
}

#CREATE ROUTE TABLE DEFINITIONS
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

#CREATE ROUTE TABLE ASSOCIATION DEFINITIONS
resource "aws_route_table_association" "main" {
  count = length(var.public_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.rtb.*.id , count.index)
}


#CREATE SECURITY GROUP DEFINITIONS
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

# #CREATE  EC2 INSTANCES
# resource "aws_instance" "fife" {
#   ami                         = var.ami
#   instance_type               = "t2.micro"
#   key_name                    = "Tinorudy01"
#   count                       = length(var.public_cidr)
#   associate_public_ip_address = true
#   monitoring                  = true
#   security_groups     = [aws_security_group.allow-access.id]
#   subnet_id                   = element(aws_subnet.public.*.id, count.index)
#   tenancy                     = "default"

# }

resource "aws_lb" "main" {
  name = "public"
  internal = false 
  load_balancer_type = "application"
  security_groups = [ aws_security_group.allow-access.id ]
  subnets = aws_subnet.public.*.id
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "TG1" {
  name = "tg1-access"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  
}

resource "aws_lb_listener" "application" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG1.arn
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "*.fiffik.co.uk"
  validation_method = "DNS"


  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "tino" {
  name         = "fiffik.co.uk"
  private_zone = false
}

resource "aws_route53_record" "tinorudy" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.tino.zone_id
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.tinorudy : record.fqdn]
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.tino.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}