resource "aws_kms_key" "eks_secrets" {
  description = "KMS key for encrypting EKS cluster secrets"
}

resource "aws_kms_key" "ebs_volumes" {
  description = "KMS key for encrypting EBS volumes"
}

output "eks_secrets_kms_key_id" {
  value = aws_kms_key.eks_secrets.id
}

output "ebs_volumes_kms_key_id" {
  value = aws_kms_key.ebs_volumes.id
}
