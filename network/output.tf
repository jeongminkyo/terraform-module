# The ID of the VPC
output "id" {
  value = aws_vpc.main.id
}

# The CIDR block of the VPC
output "cidr_block" {
  value = aws_vpc.main.cidr_block
}

# A list of public subet IDs
output "public_subnets" {
  value = aws_subnet.public.*.id
}

# A list of private subet IDs
output "private_subnets" {
  value = aws_subnet.private.*.id
}

# A list of private subet IDs
output "rds_subnets" {
  value = aws_subnet.rds.*.id
}
