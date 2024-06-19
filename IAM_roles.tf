resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# EKS IAM policy definition
resource "aws_iam_policy" "eks_policy" {
  name        = "eks-policy"
  description = "Policy for EKS to manage resources"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup",
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateRoute",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteRoute",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteVolume",
          "ec2:DescribeInstances",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeVpcs",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeAvailabilityZones",
          "ec2:DetachVolume",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyVolume",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeInternetGateways",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
          "elasticloadbalancing:AttachLoadBalancerToSubnets",
          "elasticloadbalancing:ConfigureHealthCheck",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateLoadBalancerListeners",
          "elasticloadbalancing:CreateLoadBalancerPolicy",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancerListeners",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeLoadBalancerPolicies",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DetachLoadBalancerFromSubnets",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
          "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "iam:CreateServiceLinkedRole",
        Resource = "*",
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_role_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.eks_policy.arn
}

# Output the role ARN
output "eks_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}


resource "aws_iam_role" "eks_node_role" {
  name = "eks_node_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks-nodegroup.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy definition
resource "aws_iam_policy" "eks_node_policy" {
  name        = "eks-node-policy"
  description = "Policy for EKS to manage resources"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "SharedSecurityGroupRelatedPermissions",
        Effect: "Allow",
        Action: [
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:DescribeInstances",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DeleteSecurityGroup"
        ],
        Resource: "*",
        Condition: {
          StringLike: {
            "ec2:ResourceTag/eks": "*"
          }
        }
      },
      {
        Sid: "EKSCreatedSecurityGroupRelatedPermissions",
        Effect: "Allow",
        Action: [
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:DescribeInstances",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DeleteSecurityGroup"
        ],
        Resource: "*",
        Condition: {
          StringLike: {
            "ec2:ResourceTag/eks:nodegroup-name": "*"
          }
        }
      },
      {
        Sid: "LaunchTemplateRelatedPermissions",
        Effect: "Allow",
        Action: [
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion"
        ],
        Resource: "*",
        Condition: {
          StringLike: {
            "ec2:ResourceTag/eks:nodegroup-name": "*"
          }
        }
      },
      {
        Sid: "AutoscalingRelatedPermissions",
        Effect: "Allow",
        Action: [
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:PutLifecycleHook",
          "autoscaling:PutNotificationConfiguration",
          "autoscaling:EnableMetricsCollection"
        ],
        Resource: "arn:aws:autoscaling:*:*:*:autoScalingGroupName/eks-*"
      },
      {
        Sid: "AllowAutoscalingToCreateSLR",
        Effect: "Allow",
        Condition: {
          StringEquals: {
            "iam:AWSServiceName": "autoscaling.amazonaws.com"
          }
        },
        Action: "iam:CreateServiceLinkedRole",
        Resource: "*"
      },
      {
        Sid: "AllowASGCreationByEKS",
        Effect: "Allow",
        Action: [
          "autoscaling:CreateOrUpdateTags",
          "autoscaling:CreateAutoScalingGroup"
        ],
        Resource: "*",
        Condition: {
          "StringEquals" : {
            "aws:TagKeys": [
              "eks",
              "eks:cluster-name",
              "eks:nodegroup-name"
            ]
          }
        }
      },
      {
        Sid: "AllowPassRoleToAutoscaling",
        Effect: "Allow",
        Action: "iam:PassRole",
        Resource: "*",
        Condition: {
          StringEquals: {
            "iam:PassedToService": "autoscaling.amazonaws.com"
          }
        }
      },
      {
        Sid: "AllowPassRoleToEC2",
        Effect: "Allow",
        Action: "iam:PassRole",
        Resource: "*",
        Condition: {
          StringEqualsIfExists: {
            "iam:PassedToService": [
              "ec2.amazonaws.com"
            ]
          }
        }
      },
      {
        Sid: "PermissionsToManageResourcesForNodegroups",
        Effect: "Allow",
        Action: [
          "iam:GetRole",
          "ec2:CreateLaunchTemplate",
          "ec2:DescribeInstances",
          "iam:GetInstanceProfile",
          "ec2:DescribeLaunchTemplates",
          "autoscaling:DescribeAutoScalingGroups",
          "ec2:CreateSecurityGroup",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:RunInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:GetConsoleOutput",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSubnets"
        ],
        Resource: "*"
      },
      {
        Sid: "PermissionsToCreateAndManageInstanceProfiles",
        Effect: "Allow",
        Action: [
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:AddRoleToInstanceProfile"
        ],
        Resource: "arn:aws:iam::*:instance-profile/eks-*"
      },
      {
        Sid: "PermissionsToManageEKSAndKubernetesTags",
        Effect: "Allow",
        Action: [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        Resource: "*",
        Condition: {
          "ForAnyValue:StringLike": {
            "aws:TagKeys": [
              "eks",
              "eks:cluster-name",
              "eks:nodegroup-name",
              "kubernetes.io/cluster/*"
            ]
          }
        }
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.eks_node_policy.arn
}

# Output the role ARN
output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}


# resource "aws_iam_role_policy_attachment" "eks_ebs_csi_policy" {
#   role       = aws_iam_role.eks_node_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicy"
# }

# resource "aws_iam_oidc_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.aws_eks_cluster.example.identity.oidc.issuer]
#   url             = data.aws_eks_cluster.example.identity.oidc.issuer
# }
