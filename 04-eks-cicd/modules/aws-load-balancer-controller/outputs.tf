output "service_account_name" {
  description = "Name of the service account"
  value       = "aws-load-balancer-controller"
}

output "iam_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "helm_release_name" {
  description = "Name of the Helm release"
  value       = helm_release.aws_load_balancer_controller.name
}

output "namespace" {
  description = "Namespace where the controller is deployed"
  value       = "kube-system"
}