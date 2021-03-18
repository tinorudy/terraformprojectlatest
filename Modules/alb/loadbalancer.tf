resource "aws_lb" "main" {
  name = "public"
  internal = false 
  load_balancer_type = "application"
  security_groups = [var.security_groups_id]
  subnets = var.subnet_id
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "TG1" {
  name = "tg1-access"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  
}

resource "aws_lb_listener" "application" {
  load_balancer_arn = var.aws_lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.aws_acm_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = var.aws_lb_target_group_arn
  }

}

# resource "aws_instance" "web" {
#     count = var.ec2_count
#     ami = var.ami
#     instance_type = var.instance_type
#     subnet_id = var.subnet_id

#     tags = {
#       "Name" = "Hello World"
#     }
  
# }