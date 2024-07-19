locals{
  oidc_provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  account_id = split(":", module.eks.cluster_arn)[4]
  oidc_provider_arn = "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_provider_url}"
}

resource "aws_iam_policy" "eks-autoscaler-policy" {
  name = "${var.cluster_name}-eks-autocaler-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
         "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeImages",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "eks-autoscaler-role" {
  name = "${var.cluster_name}-eks-autoscaler-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : local.oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
           "${local.oidc_provider_url}:sub" : "system:serviceaccount:autoscaler:cluster-autoscaler"
          }
        }
    }
    ]
    })
}

resource "aws_iam_role_policy_attachment" "eks-autocaler-policy-attachment" {
  role       = aws_iam_role.eks-autoscaler-role.name
  policy_arn = aws_iam_policy.eks-autoscaler-policy.arn
}

# resource "aws_iam_role_policy_attachment" "eks_role_autoscaler_policy_attachment" {
#   role       = aws_iam_role.eks_cluster_role.name
#   policy_arn = aws_iam_policy.eks-autoscaler-policy.arn
# }


resource "helm_release" "autoscaler"{
  name = "autoscaler"
  namespace = kubernetes_namespace.autoscaler.metadata[0].name
  repository = "https://github.com/csye7125-su24-team18/helm-eks-autoscaler"
  chart = "./charts/eks-cluster-autoscaler-0.1.0.tgz"
  version = "0.1.0"
  set {
    name = "annotations.role_arn"
    value = aws_iam_role.eks-autoscaler-role.arn
  }
  values = [
    file("autoscaler.yaml")
  ]
}
