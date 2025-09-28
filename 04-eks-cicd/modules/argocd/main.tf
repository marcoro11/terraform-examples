resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.argocd_chart_version

  values = [
    yamlencode({
      server = {
        extraArgs = ["--insecure"]  # For demo purposes - use HTTPS in production

        ingress = {
          enabled = var.argocd_domain != ""
          annotations = {
            "kubernetes.io/ingress.class" = "alb"
            "alb.ingress.kubernetes.io/scheme" = "internet-facing"
            "alb.ingress.kubernetes.io/target-type" = "ip"
          }
          hosts = var.argocd_domain != "" ? [var.argocd_domain] : []
          paths = ["/"]
        }

        service = {
          type = "ClusterIP"
        }
      }

      repoServer = {
        serviceAccount = {
          create = true
        }
      }

      controller = {
        serviceAccount = {
          create = true
        }
      }

      redis = {
        enabled = true
      }

      dex = {
        enabled = false
      }

      rbac = {
        create = true
        policy_csv = var.rbac_policy_csv
      }

      configs = {
        cm = {
          # ArgoCD configuration
          "timeout.reconciliation" = "180s"
          "timeout.hard" = "300s"
        }

        credentialTemplates = {
          "https-creds" = {
            url = "https://github.com"
            usernameSecret = {
              name = "github-creds"
              key  = "username"
            }
            passwordSecret = {
              name = "github-creds"
              key  = "password"
            }
          }
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  data = {
    password = bcrypt(var.argocd_admin_password)
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "sample_app" {
  count = var.create_sample_app ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "sample-app"
      namespace = var.namespace
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.git_repository_url != "" ? var.git_repository_url : "https://github.com/argoproj/argo-cd"
        targetRevision = var.git_target_revision
        path           = "docs/operator-manual/ingress/nginx"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_config_map" "argocd_rbac" {
  metadata {
    name      = "argocd-rbac-cm"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "argocd-rbac-cm"
    }
  }

  data = {
    "policy.csv" = var.rbac_policy_csv
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_secret" "git_creds" {
  count = var.git_repository_url != "" ? 1 : 0

  metadata {
    name      = "github-creds"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    username = base64encode("git")  # Placeholder - should be configured properly
    password = base64encode("token")  # Placeholder - should be configured properly
  }

  depends_on = [helm_release.argocd]
}

resource "null_resource" "wait_for_argocd" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = "kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n ${var.namespace}"
  }
}