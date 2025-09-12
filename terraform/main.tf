provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  
  # Enable automatic public IP assignment for public subnets
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets  # Use public subnets for direct access
  
  # Enable public endpoint access
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
  
  # Optional: Restrict public access to specific CIDR blocks
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]  # You might want to restrict this to specific IPs

  # Grant access to your user
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::319319364622:user/testuser1"
      username = "testuser1"
      groups   = ["system:masters"]
    }
  ]

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      
      # Add additional IAM policies for the node group
      iam_role_additional_policies = {
        AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEKSWorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKSServicePolicy = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
      }
    }
  }

  # Enable IRSA for pod IAM roles
  enable_irsa = true

  # Allow worker nodes to pull from ECR and accept NodePort traffic
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_nodeport_tcp = {
      description = "Allow NodePort access from internet"
      protocol    = "tcp"
      from_port   = 30000
      to_port     = 32767
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
