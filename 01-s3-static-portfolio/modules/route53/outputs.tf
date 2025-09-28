output "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  value       = data.aws_route53_zone.domain_zone.zone_id
}

output "record_name" {
  description = "Name of the Route53 record"
  value       = aws_route53_record.domain_record.name
}