output "grafana_url" {
  description = "URL to access Grafana dashboard"
  value       = var.grafana_domain != "" ? "https://${var.grafana_domain}" : null
}

output "prometheus_url" {
  description = "Command to access Prometheus"
  value       = "kubectl port-forward -n ${var.namespace} svc/prometheus-operated 9090:9090"
}

output "alertmanager_url" {
  description = "Command to access AlertManager"
  value       = "kubectl port-forward -n ${var.namespace} svc/alertmanager-operated 9093:9093"
}

output "grafana_admin_credentials" {
  description = "Grafana admin credentials"
  value       = "Username: admin, Password: ${var.grafana_admin_password}"
  sensitive   = true
}

output "namespace" {
  description = "Namespace where monitoring is deployed"
  value       = var.namespace
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL (if applicable)"
  value       = null  # This could be extended for CloudWatch integration
}