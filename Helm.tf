provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


resource "helm_release" "kafka" {
  name       = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  version    = "29.3.4"
  namespace  = kubernetes_namespace.kafka.metadata[0].name
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
}

# resource "helm_release" "postgres" {
#   name       = "postgres"
#   namespace  = "default"  # Specify your desired namespace
#   chart      = "postgresql"  # Path to unzipped PostgreSQL Helm chart directory
#   values     = [file("values.yaml")]  # Path to your values.yaml file

#   set {
#     name  = "image.repository"
#     value = "hsa404/webapp-db"  # Replace with your private Docker image repository
#   }

#   set {
#     name  = "image.tag"
#     value = "latest"  # Replace with your image tag
#   }

#   set {
#     name  = "image.pullSecrets"
#     value = kubernetes_secret.docker_registry_credentials.metadata.0.name  # Reference to the Kubernetes Secret containing Docker registry credentials
#   }
#   depends_on = [
#     module.eks,
#     kubernetes_secret.docker_registry_credentials
#   ]
# }

# resource "null_resource" "create_kafka_topic" {
#   depends_on = [helm_release.kafka]

#   provisioner "local-exec" {
#     command = <<-EOT
#       sleep 60  # Wait for Kafka to be fully up
#       kubectl apply -f create-kafka-topic-job.yaml
#     EOT
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = "kubectl delete -f create-kafka-topic-job.yaml"
#   }
# }
