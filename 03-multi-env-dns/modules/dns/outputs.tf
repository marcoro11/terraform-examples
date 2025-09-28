output "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  value       = local.hosted_zone_id
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "domain_validation_options" {
  description = "Certificate domain validation options"
  value       = aws_acm_certificate.main.domain_validation_options
}

output "nameservers" {
  description = "Route53 hosted zone nameservers"
  value       = try(data.aws_route53_zone.existing[0].name_servers, aws_route53_zone.main[0].name_servers)
}