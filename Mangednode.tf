# resource "aws_eks_node_group" "example" {
#   cluster_name    = aws_eks_cluster.example.name
#   node_group_name = "example-node-group"
#   node_role_arn   = aws_iam_role.eks_node_role.arn
#   subnet_ids      = aws_subnet.private[*].id

#   scaling_config {
#     desired_size = 3
#     max_size     = 6
#     min_size     = 3
#   }

#   launch_template {
#     id      = aws_launch_template.example.id
#     version = "$Latest"
#   }

#   instance_types = ["c3.large"]

#   ami_type = "AL2_x86_64"

#   capacity_type = "ON_DEMAND"

#   update_config {
#     max_unavailable = 1
#   }
# }
