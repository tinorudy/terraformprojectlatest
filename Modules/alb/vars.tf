
# variable "ec2_count" {
#     default = "1"
  
# }

# variable "ami" {}

# variable "instance_type" {
#   default = "t2.micro"
# }
variable "subnet_id" {}

variable "security_groups_id" {}

variable "vpc_id" {} 
variable "aws_lb_arn" {}
variable "aws_acm_cert_arn" {}
variable "aws_lb_target_group_arn" {}
variable "aws_lb_dns_name" {}
variable "aws_lb_zone_id" {}