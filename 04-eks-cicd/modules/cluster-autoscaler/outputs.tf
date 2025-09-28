output "service_account_name" {
  description = "Name of the service account"
  value       = "cluster-autoscaler"
}

output "iam_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "helm_release_name" {
  description = "Name of the Helm release"
  value       = helm_release.cluster_autoscaler.name
}

output "namespace" {
  description = "Namespace where the autoscaler is deployed"
  value       = "kube-system"
}