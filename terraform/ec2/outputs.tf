output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "ec2_instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.app[*].id
}

output "ec2_private_ips" {
  description = "EC2 private IPs"
  value       = aws_instance.app[*].private_ip
}
