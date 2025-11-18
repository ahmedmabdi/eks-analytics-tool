module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "eks-cluster"
  kubernetes_version = "1.30"

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

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  endpoint_public_access                   = true
  endpoint_public_access_cidrs             = ["0.0.0.0/0"]
  enable_cluster_creator_admin_permissions = true

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

    }
  }

  tags = local.tags
}
