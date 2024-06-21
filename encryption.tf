# resource "aws_kms_key" "eks_secrets" {
#   description = "KMS key for encrypting EKS cluster secrets"
# }

# resource "aws_kms_key" "ebs_volumes" {
#   description = "KMS key for encrypting EBS volumes"
# }

# output "eks_secrets_kms_key_id" {
#   value = aws_kms_key.eks_secrets.id
# }

# output "ebs_volumes_kms_key_id" {
#   value = aws_kms_key.ebs_volumes.id
# }

# resource "aws_kms_key" "eks_secrets_encryption" {
#   description             = "KMS key for EKS secrets encryption"
#   deletion_window_in_days = 10
#    policy                  = data.aws_iam_policy_document.eks_secrets_encryption_policy.json

#   tags = {
#     Name = "${var.cluster_name}-eks-secrets-encryption"
#   }
# }

# data "aws_iam_policy_document" "eks_secrets_encryption_policy" {
#   statement {
#     sid       = "Enable IAM User Permissions"
#     effect    = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#     }
#     actions   = ["kms:*"]
#     resources = ["*"]
#   }

#   statement {
#     sid       = "Allow EKS to Encrypt/Decrypt"
#     effect    = "Allow"
#     principals {
#       type = "AWS"
#       identifiers = [
#         aws_iam_role.eks_cluster_role.arn
#       ]
#     }
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey"
#     ]
#     resources = ["*"]
#   }
# }
data "aws_caller_identity" "current" {}
resource "aws_kms_key_policy" "eks_secrets_cmek_policy" {
  key_id = aws_kms_key.eks_secrets_encryption.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}
resource "aws_kms_key_policy" "eks_db_cmek_policy" {
  key_id = aws_kms_key.ebs_volume_encryption.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}
resource "aws_kms_key" "eks_secrets_encryption" {

  description              = "KMS key for EKS secrets encryption"
  deletion_window_in_days  = 10
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  tags = {
    Name = "${var.cluster_name}-eks-secrets-encryption"
  }
}





output "eks_secrets_encryption_key_arn" {
  value = aws_kms_key.eks_secrets_encryption.arn
}


resource "aws_kms_key" "ebs_volume_encryption" {
  description              = "KMS key for EBS volume encryption"
  deletion_window_in_days  = 10
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  tags = {
    Name = "${var.cluster_name}-ebs-volume-encryption"
  }
}

