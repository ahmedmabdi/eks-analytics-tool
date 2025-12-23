module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.name
  kubernetes_version = var.kubernetes_version

  addons = {
    coredns = { most_recent = true
    }
    eks-pod-identity-agent = { most_recent = true
    }
    kube-proxy = { most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.public_subnets

  endpoint_public_access                   = var.endpoint_public_access
  endpoint_public_access_cidrs             = var.endpoint_public_access_cidrs 
  enable_cluster_creator_admin_permissions = true

  enable_irsa = true

  eks_managed_node_groups = var.eks_managed_node_groups

  tags = var.tags
}
