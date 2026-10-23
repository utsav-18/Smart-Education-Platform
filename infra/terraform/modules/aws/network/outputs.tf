output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for zone in local.availability_zones : aws_subnet.public[zone].id]
}

output "private_subnet_ids" {
  value = [for zone in local.availability_zones : aws_subnet.private[zone].id]
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "service_security_group_id" {
  value = aws_security_group.service.id
}
