output "vpc_id" {
  value       = aws_vpc.spendv.id
  description = "VPC ID"
}

output "public_subnets" {
  value       = aws_subnet.public_subnets.*.id
  description = "List of subnets in the VPC"
}