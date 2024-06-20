module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  authentication_mode = "API_AND_CONFIG_MAP"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_ip_family = "ipv4"
  create_iam_role = false

 
  


  # Enable Control plane logging
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      manage_iam_role = true
    }
    # Install Amazon EKS Pod Identity Agent EKS add-on
    # pod-identity-webhook = {
    #   version = "1.7.0"
    # }
  }


  vpc_id                   = aws_vpc.terraform_vpc.id
  subnet_ids               = [aws_subnet.private_tf_subnet[0].id, aws_subnet.private_tf_subnet[1].id, aws_subnet.private_tf_subnet[2].id]
  control_plane_subnet_ids = [aws_subnet.private_tf_subnet[0].id, aws_subnet.private_tf_subnet[1].id, aws_subnet.private_tf_subnet[2].id]
  iam_role_arn = aws_iam_policy.eks_policy.arn


  eks_managed_node_groups = {
    node_group = {
      ami_type = "AL2_x86_64"
      min_size     = 1
      max_size     = 3
      desired_size = 2
      max_unavailable = 1
      instance_types = ["c3.large"]
      capacity_type  = "ON_DEMAND"
      create_iam_role = false
      iam_role_arn = aws_iam_role.eks_node_role.arn
    }
  }
    depends_on = [
    aws_iam_role.eks_cluster_role,
    aws_iam_policy.eks_policy,
    aws_iam_role_policy_attachment.eks_role_policy_attachment,
    aws_iam_role_policy_attachment.eks_node_policy_attachment,
    aws_kms_key.eks_secrets_encryption
  ]

  tags = {
    Environment = "infra"
    Terraform   = "true"
  }
  cluster_encryption_config = {
  provider_key_arn = aws_kms_key.eks_secrets_encryption.arn
  resources        = ["secrets"]
}
}

#  encryption_config {
#     resources = ["secrets"]
#     provider {
#       key_arn = var.secrets_encryption_kms_key_arn
#     }
#   }

# Cluster access entry
  # To add the current caller identity as an administrator
  # enable_cluster_creator_admin_permissions = true

  # access_entries = {
  #   # One access entry with a policy associated
  #   cluster = {
  #     kubernetes_groups = []
  #     principal_arn     = "arn:aws:iam::058264467072:root"

  #     policy_associations = {
  #       test = {
  #         policy_arn = aws_iam_policy.eks_policy.arn
  #         access_scope = {
  #           namespaces = ["default"]
  #           type       = "namespace"
  #         }
  #       }
  #     }
  #   }
  # }

  # # EKS Managed Node Group(s)
  # eks_managed_node_group_defaults = {
  #   instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  # }
