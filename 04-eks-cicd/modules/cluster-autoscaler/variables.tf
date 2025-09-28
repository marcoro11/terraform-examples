variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  type        = string
}

variable "cluster_ca_cert" {
  description = "CA certificate of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for EKS"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "chart_version" {
  description = "Version of Cluster Autoscaler chart"
  type        = string
  default     = "9.29.0"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}