provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# resource "helm_release" "metrics_server" {
#   name       = "metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   version    = "0.6.1" # Use the latest stable version or the version you need

#   # Ensure that you set the correct namespace or use the default namespace
#   namespace = "kube-system"

#   values = [<<EOF
#   apiVersion: apps/v1
#   kind: Deployment
#   metadata:
#     name: metrics-server
#     namespace: kube-system
#   spec:
#     replicas: 1
#     selector:
#       matchLabels:
#         k8s-app: metrics-server
#     template:
#       metadata:
#         labels:
#           k8s-app: metrics-server
#       spec:
#         containers:
#         - name: metrics-server
#           image: metrics-server/metrics-server:v0.6.1
#           command:
#           - /metrics-server
#           - --cert-dir=/tmp
#           - --secure-port=443
#           - --kubelet-insecure-tls
#           - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
#           - --kubelet-use-node-status-port
#           ports:
#           - containerPort: 443
#             name: main-port
#   EOF
#   ]
# }

resource "helm_release" "kafka" {
  name       = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  version    = "29.3.4"
  namespace  = kubernetes_namespace.kafka.metadata[0].name
  timeout    = 600
  values     = ["${file("values.yaml")}"]

  depends_on = [module.eks.cluster_name]
}


resource "kubernetes_secret" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = "db"
  }

  data = {
    "postgres-password" = var.postgresql_password
  }


}

resource "helm_release" "postgresql1" {
  name       = "postgresql2"
  namespace  = "db"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "15.5.9"

  set {
    name  = "postgresqlUsername"
    value = "postgres"
  }


  set {
    name  = "auth.existingSecret"
    value = kubernetes_secret.postgresql.metadata[0].name
  }

  set {
    name  = "auth.database"
    value = "cve"
  }

  set {
    name  = "auth.existingSecretPasswordKey"
    value = "postgres-password"
  }

  set {
    name  = "volumePermissions.enabled"
    value = "true"
  }

  set {
    name  = "readinessProbe.initialDelaySeconds"
    value = "30"
  }

  set {
    name  = "readinessProbe.periodSeconds"
    value = "10"
  }

  set {
    name  = "readinessProbe.timeoutSeconds"
    value = "5"
  }

  set {
    name  = "readinessProbe.successThreshold"
    value = "1"
  }

  set {
    name  = "readinessProbe.failureThreshold"
    value = "5"
  }

  set {
    name  = "storageClass"
    value = "aws-ebs-sc"
  }
  set {
    name  = "persistence.enabled"
    value = "true"
  }
  set {
    name  = "persistence.size"
    value = "10Gi"
  }

  depends_on = [module.eks.cluster_name]

  set {
    name  = "metrics.enabled"
    value = "true"
  }
  set {
    name  = "metrics.serviceMonitor.enabled"
    value = "true"
  }
  set {
    name  = "metrics.serviceMonitor.namespace"
    value = "monitoring"
  }
  set {
    name  = "metrics.serviceMonitor.labels.release"
    value = "kube-prometheus-stack"
  }
  set {
    name  = "metrics.serviceMonitor.annotations.prometheus.io/scrape"
    value = "true"
  }
  set {
    name  = "metrics.serviceMonitor.annotations.prometheus.io/port"
    value = "9187"
  }
  set {
    name  = "metrics.serviceMonitor.annotations.prometheus.io/path"
    value = "/metrics"
  }
  set {
    name  = "metrics.serviceMonitor.selector.matchLabels.app.kubernetes.io/name"
    value = "postgresql"
  }
}


