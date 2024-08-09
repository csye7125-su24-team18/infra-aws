# resource "helm_release" "cert_manager" {
#   name      = "cert-manager"
#   namespace = "cert-manager"
#   chart     = "./charts/cert-manager-v1.15.2.tgz"
#   version   = "v1.15.2" # Specify the version you need
#   values    = [file("Certificate.yaml")]
# }



# resource "kubernetes_secret" "aws_secret" {
#   depends_on = [helm_release.cert_manager]
#   metadata {
#     name      = "aws-secret"
#     namespace = "cert-manager"
#   }

#   data = {
#     "aws-access-key-id"     = "AKIAU6GDVZWHILA6TCBL"
#     "aws-secret-access-key" = "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"
#   }
# }

# resource "kubernetes_manifest" "letsencrypt_route53_cluster_issuer" {
#   depends_on = [helm_release.cert_manager, kubernetes_secret.aws_secret]
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "ClusterIssuer"
#     metadata = {
#       name = "letsencrypt-route53"
#     }
#     spec = {
#       acme = {
#         server = "https://acme-v02.api.letsencrypt.org/directory"
#         email  = "poojahusky@gmail.com" # Replace with your email address
#         privateKeySecretRef = {
#           name = "letsencrypt-route53"
#         }
#         solvers = [
#           {
#             dns01 = {
#               route53 = {
#                 region = "us-east-1" # Replace with the region where Route 53 is configured
#                 accessKeyId = {
#                   name = kubernetes_secret.aws_secret.metadata[0].name
#                   key  = "aws-access-key-id"
#                 }
#                 secretAccessKey = {
#                   name = kubernetes_secret.aws_secret.metadata[0].name
#                   key  = "aws-secret-access-key"
#                 }
#               }
#             }
#           }
#         ]
#       }
#     }
#   }
# }
# resource "kubernetes_manifest" "my_certificate" {
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "Certificate"
#     metadata = {
#       name      = "my-certificate"
#       namespace = "cert-manager" # Specify the namespace where you want to create the certificate
#     }
#     spec = {
#       secretName = "my-certificate-secret"
#       issuerRef = {
#         name = "letsencrypt-prod" # Make sure this Issuer or ClusterIssuer is already created
#         kind = "ClusterIssuer"
#       }
#       commonName = "poojacloud24.pw"
#       dnsNames = [
#         "poojacloud24.pw"
#       ]
#       duration    = "8760h" # 1 year
#       renewBefore = "360h"  # 15 days before expiration
#     }
#   }
# }



# # # Define the IAM Role for Cert-Manager in the Dev Account
# resource "aws_iam_role" "cert_manager_role_dev" {
#   provider = aws.dev
#   name     = "CertManagerRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "eks.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Attach policies to the Cert-Manager role (if needed)
# resource "aws_iam_role_policy_attachment" "cert_attachment" {
#   provider   = aws.dev
#   policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess" # or create a custom policy
#   role       = aws_iam_role.cert_manager_role.id
# }

# # If using a custom policy, you can define it as well
# resource "aws_iam_policy" "cert_manager_policy_tf" {
#   provider = aws.dev
#   name     = "CertManagerPolicy"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "route53:ChangeResourceRecordSets",
#           "route53:ListResourceRecordSets",
#           "route53:ListHostedZones",
#           "route53:GetChange",
#           "route53:ListHostedZonesByName"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Attach the custom policy to the role
# resource "aws_iam_role_policy_attachment" "cert_manager_custom_policy_attachment_tf" {
#   provider   = aws.dev
#   policy_arn = aws_iam_policy.cert_manager_policy.arn
#   role       = aws_iam_role.cert_manager_role.id
# }

# #Define the IAM Role for Cert-Manager in the Infra Account
# resource "aws_iam_role" "role_infra" {
#   provider = aws.infra
#   name     = "Role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           AWS = "arn:aws:iam::339712789902:role/CertManagerRole" # Replace with your Cert-Manager IAM role ARN in the dev account
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "cert_infra" {
#   provider = aws.infra
#   name     = "Policy"
#   role     = aws_iam_role.cert_manager_role_infra.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "route53:ChangeResourceRecordSets",
#           "route53:ListResourceRecordSets",
#           "route53:ListHostedZones",
#           "route53:GetChange",
#           "route53:ListHostedZonesByName"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "assume_policy" {
#   provider = aws.dev
#   name     = "CertManagerAssumeRolePolicy"
#   role     = aws_iam_role.cert_manager_role.id # IAM role that Cert-Manager uses in the dev profile

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = "sts:AssumeRole",
#         Resource = "arn:aws:iam::0582-6446-7072:role/CertManagerRole" # Role ARN from the infra account
#       }
#     ]
#   })
# }



# This is my old cert-manager IAM role

# resource "aws_iam_role" "cert_manager_role" {
#   provider = aws.infra
#   name     = "CertManagerRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           AWS = "arn:aws:iam::339712789902:root" # Replace with your Dev account ID
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "cert_manager_policy" {
#   provider = aws.infra
#   name     = "CertManagerPolicy"
#   role     = aws_iam_role.cert_manager_role.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "route53:ChangeResourceRecordSets",
#           "route53:ListResourceRecordSets",
#           "route53:ListHostedZones",
#           "route53:GetChange",
#           "route53:ListHostedZonesByName"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role" "cert_manager_role" {
#   provider = aws.dev
#   name     = "CertManagerRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           AWS = "arn:aws:iam::339712789902:root" # Replace with your Dev account ID
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "cert_manager_policy" {
#   provider = aws.dev
#   name     = "CertManagerPolicy"
#   role     = aws_iam_role.cert_manager_role.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "route53:ChangeResourceRecordSets",
#           "route53:ListResourceRecordSets",
#           "route53:ListHostedZones",
#           "route53:GetChange",
#           "route53:ListHostedZonesByName"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }
# resource "aws_iam_policy" "external_dns_policy" {
#   name        = "dev-cluster-external-dns-policy"
#   description = "IAM policy for ExternalDNS to manage Route 53 records"
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "route53:ChangeResourceRecordSets"
#         ],
#         "Resource" : [
#           "arn:aws:route53:::hostedzone/*"
#         ]
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "route53:ListHostedZones",
#           "route53:ListResourceRecordSets",
#           "route53:ListTagsForResource"
#         ],
#         "Resource" : [
#           "*"
#         ]
#       }
#     ]
#   })
# }