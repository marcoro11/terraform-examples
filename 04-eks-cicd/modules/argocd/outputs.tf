output "argocd_url" {
  description = "URL to access ArgoCD dashboard"
  value       = var.argocd_domain != "" ? "https://${var.argocd_domain}" : null
}

output "argocd_admin_credentials" {
  description = "ArgoCD admin credentials"
  value       = "Username: admin, Password: ${var.argocd_admin_password}"
  sensitive   = true
}

output "argocd_initial_admin_secret" {
  description = "Command to get ArgoCD initial admin password"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_port_forward_command" {
  description = "Command to port forward ArgoCD"
  value       = "kubectl port-forward -n ${var.namespace} svc/argocd-server 8080:443"
}

output "namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = var.namespace
}

output "git_repository_url" {
  description = "Configured Git repository URL"
  value       = var.git_repository_url
}