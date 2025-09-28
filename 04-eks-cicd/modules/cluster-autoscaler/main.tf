data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${var.cluster_name}-cluster-autoscaler"
  description = "IAM policy for Cluster Autoscaler"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.cluster_name}-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster_autoscaler.name
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = var.chart_version

  values = [
    yamlencode({
      cloudProvider = "aws"
      awsRegion     = var.region

      rbac = {
        create = true
        serviceAccount = {
          create = true
          name   = "cluster-autoscaler"
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
          }
        }
      }

      autoDiscovery = {
        clusterName = var.cluster_name
        enabled     = true
      }

      extraArgs = {
        "scale-down-delay-after-add" = "10m"
        "scale-down-delay-after-delete" = "10m"
        "scale-down-delay-after-failure" = "3m"
        "scale-down-unneeded-time" = "10m"
        "scale-down-unready-time" = "20m"
        "scale-down-utilization-threshold" = "0.5"
        "skip-nodes-with-local-storage" = false
        "skip-nodes-with-system-pods" = false
      }

      podDisruptionBudget = {
        maxUnavailable = 1
      }

      resources = {
        limits = {
          cpu    = "100m"
          memory = "300Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "300Mi"
        }
      }
    })
  ]
}