# variable "eks_secrets_encryption_key_arn" {
#   description = "The ARN of the KMS key for EKS secrets encryption"
#   type        = string

# }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  authentication_mode                      = var.authentication_mode
  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  cluster_ip_family                        = var.cluster_ip_family
  create_iam_role                          = false
  enable_cluster_creator_admin_permissions = true
  cluster_security_group_id                = aws_security_group.eks_sg_tf.id



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

    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.eks_ebs_csi_driver_role.arn
    }
    # Install Amazon EKS Pod Identity Agent EKS add-on
    # pod-identity-webhook = {
    #   version = "1.7.0"
    # }
  }


  vpc_id     = aws_vpc.terraform_vpc.id
  subnet_ids = [aws_subnet.private_tf_subnet[0].id, aws_subnet.private_tf_subnet[1].id, aws_subnet.private_tf_subnet[2].id]
  # control_plane_subnet_ids = [aws_subnet.private_tf_subnet[0].id, aws_subnet.private_tf_subnet[1].id, aws_subnet.private_tf_subnet[2].id]
  iam_role_arn             = aws_iam_role.eks_cluster_role.arn
  openid_connect_audiences = ["sts.amazonaws.com"]

  eks_managed_node_groups = {
    node_group = {
      ami_type                     = var.ami_type
      min_size                     = var.min_size
      max_size                     = var.max_size
      desired_size                 = var.desired_size
      update_config                = { max_unavailable = var.max_unavailable }
      instance_types               = ["${var.instance_types}"]
      capacity_type                = var.capacity_type
      create_iam_role              = false
      iam_role_arn                 = aws_iam_role.eks_node_role.arn
      iam_role_additional_policies = { AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" }
    }
  }
  depends_on = [
    aws_iam_role.eks_cluster_role,
    aws_kms_key.eks_secrets_encryption
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
  create_kms_key = false

  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks_secrets_encryption.arn
    resources        = ["secrets"]
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_external_dns                   = true
  enable_cert_manager                   = true
  cert_manager_route53_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z01032301HCNS7BLR5S"]

  tags = {
  Environment = "cert-manager" }
}

resource "aws_iam_role" "eks_ebs_csi_driver_role" {
  name = "${var.cluster_name}-eks_ebs_csi_driver_role"
  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Principal" = {
          "Federated" = module.eks.oidc_provider_arn
        },
        "Action" = "sts:AssumeRoleWithWebIdentity",
        "Condition" = {
          "StringEquals" = {
            "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:aud" : "sts.amazonaws.com",
            "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eks_ebs_csi_driver_policy" {
  name = "${var.cluster_name}-eks_ebs_csi_driver_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource" : [aws_kms_key.ebs_volume_encryption.arn],
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : [aws_kms_key.ebs_volume_encryption.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_driver_policy_attachment1" {
  role       = aws_iam_role.eks_ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::${var.account_id}:policy/${var.cluster_name}-eks_ebs_csi_driver_policy"
  depends_on = [
    aws_iam_policy.eks_ebs_csi_driver_policy
  ]
}

# resource "aws_iam_role_policy" "eks_ebs_csi_driver_policy" {
#   role       = aws_iam_role.eks_ebs_csi_driver_role.id
#   name = "${var.cluster_name}-eks_ebs_csi_driver_policy"
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "kms:CreateGrant",
#           "kms:ListGrants",
#           "kms:RevokeGrant"
#         ],
#         "Resource" : [aws_kms_key.ebs_volume_encryption.arn],
#         "Condition" : {
#           "Bool" : {
#             "kms:GrantIsForAWSResource" : "true"
#           }
#         }
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         "Resource" : [aws_kms_key.ebs_volume_encryption.arn]
#       }
#     ]
#   })
# }


resource "aws_iam_role_policy_attachment" "eks_ebs_csi_existing_driver_policy_attachment" {
  role       = aws_iam_role.eks_ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [
    module.eks
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [
    module.eks
  ]
}


#  encryption_config {
#     resources = ["secrets"]
#     provider {
#       key_arn = var.secrets_encryption_kms_key_arn
#     }
#   }

# Cluster access entry
# To add the current caller identity as an administrator


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
