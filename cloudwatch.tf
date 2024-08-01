resource "helm_release" "aws_for_fluent_bit" {
  name       = "aws-for-fluent-bit"
  namespace  = "logging"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"

  set {
    name  = "annotations.role_arn"
    value = aws_iam_role.fluent_bit.arn
  }
  set {
    name  = "image.repository"
    value = "public.ecr.aws/aws-observability/aws-for-fluent-bit"
  }

  set {
    name  = "image.tag"
    value = "2.32.2.20240516"
  }

  set {
    name  = "image.pullPolicy"
    value = "IfNotPresent"
  }

  set {
    name  = "rbac.pspEnabled"
    value = "false"
  }

  set {
    name  = "service.extraService"
    value = "HTTP_Server  On\nHTTP_Listen  0.0.0.0\nHTTP_PORT    2020\nHealth_Check On\nHC_Errors_Count 5\nHC_Retry_Failure_Count 5\nHC_Period 5"
  }

  set {
    name  = "service.parsersFiles[0]"
    value = "/fluent-bit/parsers/parsers.conf"
  }

  set {
    name  = "input.enabled"
    value = "true"
  }

  set {
    name  = "input.tag"
    value = "kube.*"
  }

  set {
    name  = "input.path"
    value = "/var/log/containers/*.log"
  }

  set {
    name  = "input.db"
    value = "/var/log/flb_kube.db"
  }

  # set {
  #   name  = "input.multilineParser"
  #   value = "\"docker, cri\""
  # }

  set {
    name  = "input.memBufLimit"
    value = "5MB"
  }

  set {
    name  = "input.skipLongLines"
    value = "On"
  }

  set {
    name  = "input.refreshInterval"
    value = "10"
  }

  set {
    name  = "cloudWatchLogs.enabled"
    value = "true"
  }

  set {
    name  = "cloudWatchLogs.match"
    value = "*"
  }

  set {
    name  = "cloudWatchLogs.region"
    value = "us-east-2"
  }

  set {
    name  = "cloudWatchLogs.logGroupName"
    value = "/aws/eks/fluentbit-cloudwatch/logs"
  }

  set {
    name  = "cloudWatchLogs.logStreamPrefix"
    value = "fluentbit-"
  }

  set {
    name  = "cloudWatchLogs.autoCreateGroup"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${var.account_id}:role/FluentBitRole-${var.cluster_name}-fluentbit"
  }

  set {
    name  = "serviceAccount.name"
    value = "fluent-bit"
  }
  set {
    name  = "daemonSet.volumes[0].name"
    value = "varlog"
  }
  set {
    name  = "daemonSet.volumes[0].hostPath.path"
    value = "/var/log"
  }
  set {
    name  = "daemonSet.volumes[1].name"
    value = "varlibdockercontainers"
  }
  set {
    name  = "daemonSet.volumes[1].hostPath.path"
    value = "/var/lib/docker/containers"
  }
  set {
    name  = "daemonSet.volumes[2].name"
    value = "fluent-bit-config"
  }
  set {
    name  = "daemonSet.volumes[2].configMap.name"
    value = "fluent-bit-config"
  }
  set {
    name  = "daemonSet.volumeMounts[0].name"
    value = "varlog"
  }
  set {
    name  = "daemonSet.volumeMounts[0].mountPath"
    value = "/var/log"
  }
  set {
    name  = "daemonSet.volumeMounts[1].name"
    value = "varlibdockercontainers"
  }
  set {
    name  = "daemonSet.volumeMounts[1].mountPath"
    value = "/var/lib/docker/containers"
  }
  set {
    name  = "daemonSet.volumeMounts[1].readOnly"
    value = "true"
  }
  set {
    name  = "daemonSet.volumeMounts[2].name"
    value = "fluent-bit-config"
  }
  set {
    name  = "daemonSet.volumeMounts[2].mountPath"
    value = "/fluent-bit/etc/"
  }
  set {
    name  = "daemonSet.volumeMounts[2].subPath"
    value = "fluent-bit.conf"
  }

  # Uncomment and modify these fields if needed
  # set {
  #   name  = "imagePullSecrets"
  #   value = ""
  # }

  # set {
  #   name  = "nameOverride"
  #   value = ""
  # }

  # set {
  #   name  = "fullnameOverride"
  #   value = ""
  # }

  # set {
  #   name  = "podSecurityContext"
  #   value = ""
  # }

  # set {
  #   name  = "containerSecurityContext"
  #   value = ""
  # }

  # set {
  #   name  = "filter.enabled"
  #   value = "true"
  # }

  # set {
  #   name  = "filter.match"
  #   value = "kube.*"
  # }

  # set {
  #   name  = "filter.kubeURL"
  #   value = "https://kubernetes.default.svc.cluster.local:443"
  # }

  # set {
  #   name  = "filter.mergeLog"
  #   value = "On"
  # }

  # set {
  #   name  = "filter.mergeLogKey"
  #   value = "data"
  # }

  # set {
  #   name  = "filter.keepLog"
  #   value = "On"
  # }

  # set {
  #   name  = "filter.k8sLoggingParser"
  #   value = "On"
  # }

  # set {
  #   name  = "filter.k8sLoggingExclude"
  #   value = "On"
  # }

  # set {
  #   name  = "filter.bufferSize"
  #   value = "32k"
  # }

  # set {
  #   name  = "cloudWatch.enabled"
  #   value = "false"
  # }

  # set {
  #   name  = "cloudWatch.match"
  #   value = "*"
  # }

  # set {
  #   name  = "cloudWatch.region"
  #   value = "us-east-1"
  # }

  # set {
  #   name  = "cloudWatch.logGroupName"
  #   value = "/aws/eks/fluentbit-cloudwatch/logs"
  # }

  # set {
  #   name  = "cloudWatch.autoCreateGroup"
  #   value = "true"
  # }

  set {
    name  = "extraOutputs"
    value = "[OUTPUT]\n    Name cloudwatch_logs\n    Match *\n    region us-east-2\n    log_group_name /aws/eks/my-cluster/fluent-bit\n    log_stream_prefix from-fluent-bit-\n    auto_create_group true"
  }
}



#IAM role
locals {
  oidc_provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  account_id        = split(":", module.eks.cluster_arn)[4]
  oidc_provider_arn = "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_provider_url}"
}

resource "aws_iam_policy" "fluent_bit_cloudwatch_policy" {
  name        = "FluentBitCloudWatchPolicy"
  description = "Custom policy for Fluent Bit to access CloudWatch Logs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
resource "aws_iam_role" "fluent_bit" {
  name = "FluentBitRole-${var.cluster_name}-fluentbit"
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
            "${local.oidc_provider_url}:sub" : "system:serviceaccount:logging:fluent-bit"
          }
        }
      }
    ]
  })
  tags = {
    Name = "fluent-bit-role"
  }
}
resource "aws_iam_role_policy_attachment" "fluent_bit_cloudwatch_policy_attachment" {
  role       = aws_iam_role.fluent_bit.name
  policy_arn = aws_iam_policy.fluent_bit_cloudwatch_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
