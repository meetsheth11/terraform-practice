output "vpc_id" {
  value = aws_vpc.meet_sheth_vpc.id
}

output "public_subnets" {
  value = aws_subnet.meetsheth_public.*.id
}

output "public_sg" {
  value = aws_security_group.mtc_sg["public"].id
}