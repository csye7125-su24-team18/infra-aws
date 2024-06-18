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