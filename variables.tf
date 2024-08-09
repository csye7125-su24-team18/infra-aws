variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpcname" {
  description = "The name of the VPC"
  type        = string
}

variable "igwname" {
  description = "The name of the Internet Gateway"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
}

variable "authentication_mode" {
  description = "The authentication mode for the EKS cluster"
  type        = string
}

variable "cluster_ip_family" {
  description = "The IP family for the EKS cluster"
  type        = string
}

variable "ami_type" {
  description = "The AMI type for the node group"
  type        = string
}

variable "capacity_type" {
  description = "The capacity type for the node group"
  type        = string
}

variable "min_size" {
  description = "The minimum size of the node group"
  type        = number
}

variable "max_size" {
  description = "The maximum size of the node group"
  type        = number
}

variable "desired_size" {
  description = "The desired size of the node group"
  type        = number
}

variable "max_unavailable" {
  description = "The maximum number of unavailable nodes during a rolling update"
  type        = number
}

variable "instance_types" {
  description = "The instance types for the node group"
  type        = string
}

variable "postgresql_password" {
  description = "The password for the PostgreSQL database"
  type        = string
}
