cluster_name    = "my-eks-cluster"
cluster_version = "1.28"
environment     = "dev"

aws_region = "us-west-2"

vpc_cidr = "10.0.0.0/16"

node_groups = {
  general = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    min_size      = 1
    max_size      = 5
    desired_size  = 3
    disk_size     = 50
    ami_type      = "AL2_x86_64"
    labels = {
      role = "general"
    }
    tags = {}
  }
  spot = {
    instance_types = ["t3.medium", "t3.large"]
    capacity_type  = "SPOT"
    min_size      = 0
    max_size      = 10
    desired_size  = 2
    disk_size     = 50
    ami_type      = "AL2_x86_64"
    labels = {
      role = "spot"
    }
    tags = {
      SpotInstance = "true"
    }
  }
}

enable_cluster_autoscaler            = true
enable_aws_load_balancer_controller  = true
enable_ebs_csi_driver               = true

enable_monitoring = true
grafana_admin_password = "ChangeMe123!"  # Use a strong password
grafana_domain = "grafana.yourdomain.com"  # Optional

enable_argocd = true
argocd_admin_password = "ChangeMe123!"  # Use a strong password
argocd_domain = "argocd.yourdomain.com"  # Optional
git_repository_url = "https://github.com/yourusername/k8s-apps.git"
git_target_revision = "main"

deploy_sample_app = false
sample_app_domain = "app.yourdomain.com"

tags = {
  Owner       = "Platform"
  Project     = "EKS-Cluster"
  Environment = "Development"
  CostCenter  = "Infrastructure"
}