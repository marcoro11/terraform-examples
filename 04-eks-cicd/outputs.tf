output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = module.eks_cluster.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks_cluster.cluster_security_group_id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "node_groups" {
  description = "EKS node groups information"
  value       = module.eks_cluster.node_groups
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider for EKS"
  value       = module.eks_cluster.oidc_provider_arn
}

output "grafana_url" {
  description = "URL to access Grafana dashboard"
  value       = var.enable_monitoring && var.grafana_domain != "" ? "https://${var.grafana_domain}" : null
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = var.enable_monitoring ? "kubectl port-forward -n monitoring svc/prometheus-server 9090:80" : null
}

output "argocd_url" {
  description = "URL to access ArgoCD dashboard"
  value       = var.enable_argocd && var.argocd_domain != "" ? "https://${var.argocd_domain}" : null
}

output "argocd_initial_admin_secret" {
  description = "Command to get ArgoCD initial admin password"
  value       = var.enable_argocd ? "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d" : null
  sensitive   = true
}

output "sample_app_url" {
  description = "URL to access sample application"
  value       = var.deploy_sample_app && var.sample_app_domain != "" ? "https://${var.sample_app_domain}" : null
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}

output "useful_commands" {
  description = "Useful commands for cluster management"
  value = {
    get_nodes        = "kubectl get nodes"
    get_pods         = "kubectl get pods --all-namespaces"
    get_services     = "kubectl get services --all-namespaces"
    describe_cluster = "kubectl cluster-info"
    port_forward_grafana = var.enable_monitoring ? "kubectl port-forward -n monitoring svc/grafana 3000:80" : null
    port_forward_argocd  = var.enable_argocd ? "kubectl port-forward -n argocd svc/argocd-server 8080:443" : null
  }
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks_cluster.cluster_iam_role_arn
}

output "node_groups_iam_role_arns" {
  description = "IAM role ARNs of the EKS node groups"
  value       = module.eks_cluster.node_groups_iam_role_arns
}