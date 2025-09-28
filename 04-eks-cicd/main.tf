terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"
  
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
  
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  
  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = local.common_tags
}

module "eks_cluster" {
  source = "./modules/eks-cluster"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  
  node_groups = var.node_groups
  
  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  enable_ebs_csi_driver = var.enable_ebs_csi_driver
  
  tags = local.common_tags
  
  depends_on = [module.vpc]
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
    }
  }
}

module "monitoring" {
  count = var.enable_monitoring ? 1 : 0
  
  source = "./modules/monitoring"
  
  cluster_name = var.cluster_name
  namespace    = "monitoring"
  
  grafana_admin_password = var.grafana_admin_password
  grafana_domain        = var.grafana_domain
  
  enable_persistent_storage = true
  storage_class            = "gp2"
  
  tags = local.common_tags
  
  depends_on = [module.eks_cluster]
}

module "argocd" {
  count = var.enable_argocd ? 1 : 0
  
  source = "./modules/argocd"
  
  cluster_name = var.cluster_name
  namespace    = "argocd"
  
  argocd_admin_password = var.argocd_admin_password
  argocd_domain        = var.argocd_domain
  
  git_repository_url = var.git_repository_url
  git_target_revision = var.git_target_revision
  
  tags = local.common_tags
  
  depends_on = [module.eks_cluster]
}

module "sample_app" {
  count = var.deploy_sample_app ? 1 : 0
  
  source = "./modules/sample-app"
  
  cluster_name = var.cluster_name
  namespace    = "default"
  app_name     = "sample-web-app"
  
  replicas = 3
  image    = "nginx:1.21"
  
  enable_ingress = true
  ingress_host   = var.sample_app_domain
  
  tags = local.common_tags
  
  depends_on = [module.eks_cluster]
}

locals {
  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
    CreatedBy   = data.aws_caller_identity.current.user_id
    Region      = data.aws_region.current.name
    Cluster     = var.cluster_name
  })
}