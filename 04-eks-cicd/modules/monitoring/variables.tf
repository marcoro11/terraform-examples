variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}

variable "grafana_domain" {
  description = "Domain for Grafana dashboard"
  type        = string
  default     = ""
}

variable "enable_persistent_storage" {
  description = "Enable persistent storage for monitoring components"
  type        = bool
  default     = true
}

variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
  default     = "gp2"
}

variable "prometheus_chart_version" {
  description = "Version of kube-prometheus-stack chart"
  type        = string
  default     = "45.0.0"
}

variable "enable_loki" {
  description = "Enable Loki for centralized logging"
  type        = bool
  default     = false
}

variable "loki_chart_version" {
  description = "Version of Loki chart"
  type        = string
  default     = "2.9.10"
}

variable "enable_external_monitoring" {
  description = "Enable monitoring of external services"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}