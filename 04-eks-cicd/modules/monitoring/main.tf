resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = var.prometheus_chart_version

  values = [
    yamlencode({
      grafana = {
        enabled = true
        adminPassword = var.grafana_admin_password

        ingress = {
          enabled = var.grafana_domain != ""
          annotations = {
            "kubernetes.io/ingress.class" = "alb"
            "alb.ingress.kubernetes.io/scheme" = "internet-facing"
            "alb.ingress.kubernetes.io/target-type" = "ip"
          }
          hosts = var.grafana_domain != "" ? [var.grafana_domain] : []
          paths = ["/"]
        }

        persistence = {
          enabled = var.enable_persistent_storage
          size    = "10Gi"
          storageClass = var.storage_class
        }

        additionalDataSources = [
          {
            name = "Loki"
            type = "loki"
            url  = "http://loki.loki:3100"
            access = "proxy"
          }
        ]
      }

      prometheus = {
        prometheusSpec = {
          retention = "30d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "50Gi"
                  }
                }
              }
            }
          }
        }

        ingress = {
          enabled = false  # Access via kubectl port-forward
        }
      }

      alertmanager = {
        enabled = true

        ingress = {
          enabled = false  # Access via kubectl port-forward
        }
      }

      nodeExporter = {
        enabled = true
      }

      kubeStateMetrics = {
        enabled = true
      }

      prometheusOperator = {
        enabled = true
      }
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

resource "helm_release" "loki" {
  count = var.enable_loki ? 1 : 0

  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = "loki"
  version    = var.loki_chart_version

  values = [
    yamlencode({
      loki = {
        persistence = {
          enabled = var.enable_persistent_storage
          size    = "10Gi"
          storageClass = var.storage_class
        }
      }

      promtail = {
        enabled = true
      }

      grafana = {
        enabled = false  # We use the main Grafana
      }
    })
  ]
}

resource "kubernetes_namespace" "loki" {
  count = var.enable_loki ? 1 : 0

  metadata {
    name = "loki"
    labels = {
      name = "loki"
    }
  }
}

resource "kubernetes_manifest" "external_servicemonitor" {
  count = var.enable_external_monitoring ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "external-services"
      namespace = var.namespace
    }
    spec = {
      selector = {
        matchLabels = {
          app = "external-service"
        }
      }
      endpoints = [
        {
          port     = "http"
          interval = "30s"
        }
      ]
    }
  }

  depends_on = [helm_release.prometheus]
}

resource "kubernetes_manifest" "custom_alerts" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "custom-alerts"
      namespace = var.namespace
    }
    spec = {
      groups = [
        {
          name = "custom.rules"
          rules = [
            {
              alert = "HighPodRestartRate"
              expr  = "rate(kube_pod_container_status_restarts_total[5m]) > 0.1"
              for   = "10m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "High pod restart rate detected"
                description = "Pod {{$labels.pod}} in namespace {{$labels.namespace}} is restarting frequently"
              }
            },
            {
              alert = "NodeDiskPressure"
              expr  = "kube_node_status_condition{condition='DiskPressure', status='True'} == 1"
              for   = "5m"
              labels = {
                severity = "critical"
              }
              annotations = {
                summary     = "Node disk pressure detected"
                description = "Node {{$labels.node}} is under disk pressure"
              }
            }
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.prometheus]
}