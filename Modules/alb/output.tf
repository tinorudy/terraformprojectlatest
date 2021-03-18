output "aws_lb_arn" {
    value = aws_lb.main.arn
  
}

output "aws_lb_target_group_arn" {
    value = aws_lb_target_group.TG1.arn
  
}

output "aws_lb_dns_name" {
  value = aws_lb.main.dns_name
}

output "aws_lb_zone_id" {
  value =  aws_lb.main.zone_id
  
}