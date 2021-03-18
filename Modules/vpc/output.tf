output "vpc_id" {
    value = aws_vpc.main.id
  
}

output "subnet_id" {
    value = aws_subnet.public.*.id
  
}

output "igw_id" {
    value = aws_internet_gateway.igw.id
 
}

output "route_table_id" {
    value = aws_route_table.rtb.id
  
}

output "security_groups_id" {
    value = aws_security_group.allow-access.id
  
}