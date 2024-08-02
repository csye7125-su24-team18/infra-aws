resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

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
    value = "LoadBalancer"
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

# Ingress for Prometheus
resource "kubernetes_ingress" "prometheus" {
  metadata {
    name      = "prometheus-ingress"
    namespace = "monitoring"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      host = "prometheus.poojacloud24.pw"
      http {
        path {
          path = "/"
          backend {
            service_name = "prometheus-prometheus-kube-prometheus-prometheus"
            service_port = 9090
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "grafana" {
  metadata {
    name      = "grafana-ingress"
    namespace = "monitoring"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      host = "grafana.poojacloud24.pw"
      http {
        path {
          path = "/"
          backend {
            service_name = "grafana"
            service_port = 80
          }
        }
      }
    }
  }
}
