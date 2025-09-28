variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace for the application"
  type        = string
  default     = "default"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 3
}

variable "image" {
  description = "Container image"
  type        = string
  default     = "nginx:1.21"
}

variable "enable_ingress" {
  description = "Enable ingress for the application"
  type        = bool
  default     = true
}

variable "ingress_host" {
  description = "Host for ingress"
  type        = string
  default     = ""
}

variable "enable_hpa" {
  description = "Enable Horizontal Pod Autoscaler"
  type        = bool
  default     = false
}

variable "min_replicas" {
  description = "Minimum number of replicas for HPA"
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Maximum number of replicas for HPA"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}