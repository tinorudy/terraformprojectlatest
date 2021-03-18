provider "aws" {
  profile = "default"
  region = "eu-west-1"
}

module "my_vpc" {
    source = "../Modules/vpc"
    vpc_cidr = "192.167.0.0/16"
    tenancy = "default"
    vpc_id =  module.my_vpc.vpc_id
    public_cidr = ["192.167.0.0/28" ,"192.167.0.16/28"]
    public_az = ["eu-west-1b","eu-west-1c"]
    private_cidr = ["192.167.1.0/28" ,"192.167.1.16/28"]
    private_az = ["eu-west-1a","eu-west-1c"]
    igw_id = module.my_vpc.igw_id
    subnet_id = module.my_vpc.subnet_id
    route_table_id = module.my_vpc.route_table_id
    security_groups_id = module.my_vpc.security_groups_id

}

module "my_asg" {
  source = "../Modules/asg"
  ami = "ami-079d9017cb651564d"
  security_groups_id = module.my_vpc.security_groups_id
  subnet_id = module.my_vpc.subnet_id
  aws_launch_template_id = module.my_asg.aws_launch_template_id
}



module "my_alb" {
  source = "../Modules/alb"
  subnet_id = module.my_vpc.subnet_id
  security_groups_id = module.my_vpc.security_groups_id
  vpc_id = module.my_vpc.vpc_id
  aws_lb_target_group_arn = module.my_alb.aws_lb_target_group_arn
  aws_acm_cert_arn = module.my_cert.aws_acm_cert_arn
  aws_lb_arn = module.my_alb.aws_lb_arn
  aws_lb_dns_name = module.my_alb.aws_lb_dns_name
  aws_lb_zone_id = module.my_alb.aws_lb_zone_id
}

module "my_cert" {
  source = "../Modules/tls"
  aws_acm_cert_arn = module.my_cert.aws_acm_cert_arn
  aws_lb_dns_name = module.my_alb.aws_lb_dns_name
  zone_id = module.my_cert.zone_id
  aws_lb_zone_id = module.my_alb.aws_lb_zone_id
 
  
}