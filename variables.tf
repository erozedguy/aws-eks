# General
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "dev-us-east-1"
}

variable "cluster_version" {
  type    = string
  default = "1.27"
}

# VPC config
variable "subnets_id" {
  type = object({
    private_subnets_id = list(string)
    public_subnets_id  = list(string)
  })
  default = {
    private_subnets_id = [""]
    public_subnets_id  = [""]
  }
}

variable "endpoint_private_access" {
  type    = bool
  default = false
}

variable "endpoint_public_access" {
  type    = bool
  default = false
}

variable "public_access_cidrs" {
  type    = list(string)
  default = []
}

variable "cluster_security_group_id" {
  type    = list(string)
  default = []
}

# Logging
variable "cluster_logs_types" {
  type    = list(string)
  default = []
}

# Encryption
variable "cluster_encryption" {
  type = object({
    enable    = bool
    key_arn   = string
    resources = list(string)
  })
  default = {
    enable   = false
    key_arn  = ""
    resources = []
  }
}

# Cluster Networking
variable "cluster_networking" {
  type = object({
    service_cidr = string
    ip_family    = string
  })
  default = {
    service_cidr = "172.16.0.0/12"
    ip_family    = "ipv4"
  }
}

# Node Group
variable "node_groups" {
  type = list(object({
    name           = string
    k8s_version    = string 
    instance_types = list(string)
    ami_type       = string
    capacity_type  = string
    disk_size      = number
    scaling_config = object({
      desired_size = number
      min_size     = number
      max_size     = number
    })
    update_config = object({
      max_unavailable = number
    })
  }))
  default = [
    {
      name           = "t3-large-spot"
      k8s_version    = "1.27"
      instance_types = ["t3.large"]
      ami_type       = "AL2_x86_64"
      capacity_type  = "SPOT"
      disk_size      = 20
      scaling_config = {
        desired_size = 2
        max_size     = 3
        min_size     = 1
      }
      update_config = {
        max_unavailable = 1
      }
    },
  ]

}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
  default = [
    {
      name    = "kube-proxy"
      version = "v1.22.6-eksbuild.1"
    },
    {
      name    = "vpc-cni"
      version = "v1.11.0-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.8.7-eksbuild.1"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.6.2-eksbuild.0"
    }
  ]
}