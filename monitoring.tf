

# resource "helm_release" "prometheus" {
#   name       = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"
#   namespace  = "monitoring"

#   set {
#     name  = "prometheus.prometheusSpec.serviceMonitorSelector.matchLabels.release"
#     value = "prometheus"
#   }
#   set {
#     name  = "prometheus.prometheusSpec.serviceAccountName"
#     value = "prometheus"
#   }
# }

# resource "helm_release" "kafka_exporter" {
#   name       = "kafka-exporter"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kafka-exporter" # Adjust if the chart name is different
#   version    = " 2.10.0"        # Use the appropriate version
#   namespace  = "monitoring"
#   set {
#     name  = "serviceMonitor.enabled"
#     value = "true"
#   }
#   set {
#     name  = "serviceMonitor.namespace"
#     value = "monitoring"
#   }
# }

# resource "helm_release" "postgres_exporter" {
#   name       = "postgres-exporter"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "prometheus-postgres-exporter"
#   namespace  = "monitoring"

#   set {
#     name  = "serviceMonitor.enabled"
#     value = "true"
#   }
#   set {
#     name  = "serviceMonitor.namespace"
#     value = "monitoring"
#   }
# }

# resource "helm_release" "grafana" {
#   name       = "grafana"
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "grafana"
#   namespace  = "monitoring"

#   set {
#     name  = "service.type"
#     value = "LoadBalancer"
#   }
#   set {
#     name  = "adminPassword"
#     value = "root"
#   }
#   set {
#     name  = "serviceMonitorSelector.matchLabels.release"
#     value = "grafana"
#   }
# }
