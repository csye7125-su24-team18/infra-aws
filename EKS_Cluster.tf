module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "dev-cluster"
  cluster_version = "1.29"
  authentication_mode = "API_AND_CONFIG_MAP"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_ip_family = "ipv4"
  # encryption_config = [
  #   {
  #     provider = {
  #       key_arn = aws_kms_key.eks_secrets.arn
  #     }
  #     resources = ["secrets"]
  #   }
  # ]

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
    # Install Amazon EKS Pod Identity Agent EKS add-on
    # pod-identity-webhook = {
    #   version = "1.7.0"
    # }
  }


  vpc_id                   = aws_vpc.terraform_vpc.id
  subnet_ids               = [aws_subnet.private_tf_subnet[0].id, aws_subnet.private_tf_subnet[1].id, aws_subnet.private_tf_subnet[2].id]
  control_plane_subnet_ids = [aws_subnet.private_tf_subnet[0].id, aws_subnet.private_tf_subnet[1].id, aws_subnet.private_tf_subnet[2].id]
  iam_role_arn = aws_iam_policy.eks_policy.arn
  # # EKS Managed Node Group(s)
  # eks_managed_node_group_defaults = {
  #   instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  # }

  eks_managed_node_groups = {
    node_group = {
      ami_type = "AL2_x86_64"
      min_size     = 1
      max_size     = 3
      desired_size = 2
      max_unavailable = 1
      instance_types = ["c3.large"]
      capacity_type  = "ON_DEMAND"
    }
  }

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

    depends_on = [
    aws_iam_role.eks_cluster_role,
    aws_iam_policy.eks_policy,
    aws_iam_role_policy_attachment.eks_role_policy_attachment,
    aws_iam_role_policy_attachment.eks_node_policy_attachment
  ]

  tags = {
    Environment = "infra"
    Terraform   = "true"
  }
}
