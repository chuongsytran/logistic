output "vpc_id" {
  value = aws_vpc.logistic_vpc.id
}

output "public_subnet_id_1a" {
  value = aws_subnet.logistic_public_subnet_1a.id
}

output "public_subnet_id_1b" {
  value = aws_subnet.logistic_public_subnet_1b.id
}

output "private_subnet_id_1a" {
  value = aws_subnet.logistic_private_subnet_1a.id
}

output "private_subnet_id_1b" {
  value = aws_subnet.logistic_private_subnet_1b.id
}
