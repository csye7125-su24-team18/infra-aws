resource "aws_vpc" "terraform_vpc" {
  cidr_block = var.vpc_cidr
  #   enable_dns_support   = true
  #   enable_dns_hostnames = true
  tags = {
    Name = var.vpcname
  }
}

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = var.igwname
  }
}


resource "aws_security_group" "eks_sg_tf" {
  vpc_id = aws_vpc.terraform_vpc.id
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   from_port = 15017
  #   to_port   = 15017
  #   protocol  = "tcp"
  #   # Assuming you want to allow traffic from within the VPC
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    from_port = 15000
    to_port   = 16000
    protocol  = "tcp"
    # Assuming you want to allow traffic from within the VPC
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}

output "vpc_id" {
  value = aws_vpc.terraform_vpc.id
}

# resource "aws_security_group_rule" "allow_istio_webhook" {
#   type        = "ingress"
#   from_port    = 15017
#   to_port      = 15017
#   protocol     = "tcp"
#   security_group_id = ""
#   cidr_blocks  = ["0.0.0.0/0"]  # Update this as per your security requirements
# }



output "security_group_id" {
  value = aws_security_group.eks_sg_tf.id
}
