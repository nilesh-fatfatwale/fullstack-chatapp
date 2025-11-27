output "vpc_id" {
  value = module.vpc.vpc_id
  description = "vpc id"
}

output "public_ip" {
  value = aws_instance.myinstance.public_ip
}
