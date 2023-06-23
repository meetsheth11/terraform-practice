output "vpc_id" {
  value = aws_vpc.meet_sheth_vpc.id
}

output "public_subnets" {
  value = aws_subnet.meetsheth_public.*.id
}

output "meet_public_sg" {
  value = aws_security_group.meet_public_sg["public"].id
}