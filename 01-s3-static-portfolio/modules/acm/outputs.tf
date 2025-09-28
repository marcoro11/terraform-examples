output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = aws_acm_certificate.ssl_certificate.arn
}