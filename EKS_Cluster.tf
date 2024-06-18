resource "aws_eks_cluster" "example" {
  name     = "example-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.public[*].id
  }

  kubernetes_network_config {
    ip_family = "ipv4"
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
  }

  logging {
    cluster_logging {
      enabled = true
      types   = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    }
  }

  version = "1.29"

  endpoint_public_access  = true
  endpoint_private_access = true
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name      = aws_eks_cluster.example.name
  addon_name        = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name      = aws_eks_cluster.example.name
  addon_name        = "ebs-csi"
  resolve_conflicts = "OVERWRITE"
}
