output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.compute.alb_zone_id
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.compute.alb_dns_name}"
}

output "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.auto_scaling_group_name
}

output "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.compute.auto_scaling_group_arn
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.rds_endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.database.rds_port
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = module.database.redis_endpoint
}

output "redis_port" {
  description = "ElastiCache Redis port"
  value       = module.database.redis_port
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.compute.bastion_public_ip
}

output "bastion_security_group_id" {
  description = "Security group ID of the bastion host"
  value       = module.security.bastion_security_group_id
}

output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_url
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.monitoring.sns_topic_arn
}

output "connection_info" {
  description = "Information for connecting to resources"
  value = {
    application_url = "http://${module.compute.alb_dns_name}"
    ssh_bastion     = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${module.compute.bastion_public_ip}"
    ssh_web_server  = "ssh -i ~/.ssh/${var.key_pair_name}.pem -J ec2-user@${module.compute.bastion_public_ip} ec2-user@<private-ip>"
  }
}