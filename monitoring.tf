resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  set {
    name  = "prometheusOperator.createCustomResource"
    value = "false"
  }
  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelector.matchLabels.release"
    value = "prometheus"
  }
  set {
    name  = "prometheus.prometheusSpec.serviceAccountName"
    value = "prometheus"
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  set {
    name  = "adminPassword"
    value = "root"
  }
  set {
    name  = "serviceMonitorSelector.matchLabels.release"
    value = "grafana"
  }
}



