provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  config_path            = "C:\\Users\\pooja\\.kube\\config"
}

# resource "kubernetes_secret" "docker_registry_credentials" {
#   metadata {
#     name      = "docker-registry-creds"
#     namespace = "db"
#   }

#   type = "kubernetes.io/dockerconfigjson"

#   data = {
#     ".dockerconfigjson" = "eyJhdXRocyI6eyJodHRwczovL2luZGV4LmRvY2tlci5pby92MS8iOnsidXNlcm5hbWUiOiJoc2E0MDQiLCJwYXNzd29yZCI6ImRja3JfcGF0X1NkbHQ4LW9oTlVKMHcwbWVJQlNNMmhrdlAwVSIsImVtYWlsIjoiYWdyYXdhbC5oYXJzaEBub3J0aGVhc3Rlcm4uZWR1IiwiYXV0aCI6ImFITmhOREEwT21SamEzSmZjR0YwWDFOa2JIUTRMVzlvVGxWS01IY3diV1ZKUWxOTk1taHJkbEF3VlE9PSJ9fX0="
#   }

#   depends_on = [kubernetes_namespace.db]
# }

