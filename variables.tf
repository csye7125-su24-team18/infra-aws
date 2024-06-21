variable "region" {
  default = "us-east-1"
}

//Setup VPC variables
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "vpcname" {
  default = "terraform-vpc"
}

variable "igwname" {
  default = "terraform-igw"
}

variable "cluster_name" {
  default = "dev-cluster"
}

variable "account_id" {
  default = "339712789902"
}

variable "cluster_version" {
  default = "1.29"
}

variable "authentication_mode" {
  default = "API_AND_CONFIG_MAP"
}

variable "cluster_ip_family" {
  default = "ipv4"
}

variable "ami_type" {
  default = "AL2_x86_64"
}

variable "capacity_type" {
  default = "ON_DEMAND"
}
