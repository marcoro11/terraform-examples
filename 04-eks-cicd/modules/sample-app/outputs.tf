output "app_url" {
  description = "URL to access the application"
  value       = var.enable_ingress && var.ingress_host != "" ? "http://${var.ingress_host}" : null
}

output "service_name" {
  description = "Kubernetes service name"
  value       = kubernetes_service.app.metadata[0].name
}

output "namespace" {
  description = "Namespace where the application is deployed"
  value       = var.namespace
}

output "deployment_name" {
  description = "Kubernetes deployment name"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "replicas" {
  description = "Number of replicas"
  value       = var.replicas
}