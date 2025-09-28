variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_admin_password" {
  description = "Admin password for ArgoCD"
  type        = string
  sensitive   = true
}

variable "argocd_domain" {
  description = "Domain for ArgoCD dashboard"
  type        = string
  default     = ""
}

variable "argocd_chart_version" {
  description = "Version of ArgoCD Helm chart"
  type        = string
  default     = "5.46.0"
}

variable "git_repository_url" {
  description = "Git repository URL for ArgoCD applications"
  type        = string
  default     = ""
}

variable "git_target_revision" {
  description = "Git target revision (branch/tag)"
  type        = string
  default     = "main"
}

variable "create_sample_app" {
  description = "Create a sample ArgoCD application"
  type        = bool
  default     = false
}

variable "rbac_policy_csv" {
  description = "RBAC policy CSV for ArgoCD"
  type        = string
  default     = <<-EOF
g, alice@example.com, role:admin
g, bob@example.com, role:readonly
EOF
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}