
# Apply Cert-Manager CRDs
resource "null_resource" "cert_manager_crds" {
  provisioner "local-exec" {
    command = "kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.15.2/cert-manager.crds.yaml"
  }


  # Add a time delay to ensure CRDs are registered
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "helm_release" "cert_manager" {


  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  #   create_namespace = true
  version = "v1.15.2" # Replace with the latest version

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# resource "helm_release" "cert_manager" {
#   name       = "cert-manager"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "cert-manager"
#   version    = "1.3.15"

#   namespace = "cert-manager"

#   create_namespace = true

#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
# }
resource "kubernetes_secret" "aws_secret" {
  depends_on = [helm_release.cert_manager]
  metadata {
    name      = "aws-secret"
    namespace = "cert-manager"
  }

  data = {
    "aws-access-key-id"     = "AKIAU6GDVZWHILA6TCBL"
    "aws-secret-access-key" = "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"
  }
}
resource "kubernetes_manifest" "letsencrypt_route53_cluster_issuer" {
  depends_on = [helm_release.cert_manager, kubernetes_secret.aws_secret]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-route53"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "poojahusky@gmail.com" # Replace with your email address
        privateKeySecretRef = {
          name = "letsencrypt-route53"
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region = "us-east-1" # Replace with the region where Route 53 is configured
                accessKeyId = {
                  name = kubernetes_secret.aws_secret.metadata[0].name
                  key  = "aws-access-key-id"
                }
                secretAccessKey = {
                  name = kubernetes_secret.aws_secret.metadata[0].name
                  key  = "aws-secret-access-key"
                }
              }
            }
          }
        ]
      }
    }
  }
}

resource "aws_iam_role" "cert_manager_role" {
  provider = aws.infra
  name     = "CertManagerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::339712789902:root" # Replace with your Dev account ID
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cert_manager_policy" {
  provider = aws.infra
  name     = "CertManagerPolicy"
  role     = aws_iam_role.cert_manager_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
          "route53:ListHostedZones",
          "route53:GetChange",
          "route53:ListHostedZonesByName"
        ],
        Resource = "*"
      }
    ]
  })
}

