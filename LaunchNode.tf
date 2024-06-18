resource "aws_launch_template" "example" {
  name_prefix   = "example-eks-node"
  image_id      = data.aws_ami.eks.id
  instance_type = "c3.large"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp2"
    }
  }

  key_name = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.eks_node.id]
  }
}

data "aws_ami" "eks" {
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS optimized AMI account
  filter {
    name   = "name"
    values = ["*amazon-eks-node-1.29*"]
  }
}
