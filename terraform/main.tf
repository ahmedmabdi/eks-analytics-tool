module "vpc" {
  source = "./modules/vpc"

  name            = local.name
  cidr            = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]

}

module "eks" {
  source = "./modules/eks"

  name               = "eks-cluster"
  kubernetes_version = "1.30"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets

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
module "nginx_ingress" {
  source = "./modules/helm-addon"

  name       = "nginx-ingress-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "nginx-ingress"

  values_file = "${path.module}/../helm-values/nginx-ingress.yaml"

  depends_on = [module.eks]
}

module "cert_manager" {
  source = "./modules/helm-addon"

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"

  values_file = "${path.module}/../helm-values/cert-manager.yaml"

  depends_on = [
    module.cert_manager_pod_identity
  ]
}
module "external_dns" {
  source = "./modules/helm-addon"

  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  namespace  = "external-dns"

  values_file = "${path.module}/../helm-values/external-dns.yaml"

  depends_on = [
    module.external_dns_pod_identity
  ]
}
module "argocd" {
  source = "./modules/helm-addon"

  name          = "argocd"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  chart_version = "8.6.1"
  namespace     = "argo-cd"
  timeout       = 600

  values_file = "${path.module}/../helm-values/argocd.yaml"

  depends_on = [
    module.nginx_ingress,
    module.cert_manager,
    module.external_dns
  ]
}
module "prometheus" {
  source = "./modules/helm-addon"

  name          = "prometheus"
  repository    = "https://prometheus-community.github.io/helm-charts"
  chart         = "kube-prometheus-stack"
  chart_version = "56.6.0"
  namespace     = "monitoring"

  values_file = "${path.module}/../helm-values/monitoring.yaml"

  depends_on = [
    module.nginx_ingress,
    module.cert_manager,
    module.external_dns
  ]
}
module "rds" {
  source = "./modules/rds"

  project_name    = local.name
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  db_identifier       = "umami-db"
  db_name             = "umami"
  instance_type       = "db.t3.micro"
  allocated_storage   = 20
  publicly_accessible = true
  rds_username        = data.aws_ssm_parameter.rds_username.value
  rds_password        = data.aws_ssm_parameter.rds_password.value

}

module "cert_manager_pod_identity" {
  source          = "./modules/cm-pod-identity"
  name            = "cert-manager"
  cluster_name    = local.name
  service_account = "cert-manager"
  namespace       = "cert-manager"

  attach_cert_manager_policy = true
  cert_manager_hosted_zone_arns = [
    local.hosted_zone
  ]

  depends_on = [module.eks]
  tags       = local.tags
}

module "external_dns_pod_identity" {
  source          = "./modules/ed-pod-identity"
  name            = "external-dns"
  cluster_name    = local.name
  service_account = "external-dns"
  namespace       = "external-dns"

  attach_external_dns_policy = true
  external_dns_hosted_zone_arns = [
    local.hosted_zone
  ]

  depends_on = [module.eks]
  tags       = local.tags
}

resource "aws_route53_record" "argocd" {
  zone_id = local.zone_id
  name    = "argocd.ahmedumami.click"
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_ingress_v1.argocd.status[0].load_balancer[0].ingress[0].hostname]
}

resource "aws_ssm_parameter" "database_url" {
  name = "/umami/DATABASE_URL"
  type = "SecureString"

  value = "postgresql://${urlencode(data.aws_ssm_parameter.rds_username.value)}:${urlencode(data.aws_ssm_parameter.rds_password.value)}@${module.rds.endpoint}/${module.rds.db_name}"
}

resource "kubernetes_secret_v1" "umami_db_secret" {
  metadata {
    name      = "umami-db-secret"
    namespace = "app"
  }

  data = {
    database_url = aws_ssm_parameter.database_url.value
  }

  type = "Opaque"
}
resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_secret_v1" "grafana_admin_secret" {
  depends_on = [kubernetes_namespace_v1.monitoring]
  metadata {
    name      = "grafana-admin-secret"
    namespace = "monitoring"
  }

  data = {
    admin_password = base64encode(data.aws_ssm_parameter.grafana_password.value)
  }

  type = "Opaque"
}

data "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-server"
    namespace = "argo-cd"
  }
  depends_on = [module.argocd]
}

data "aws_ssm_parameter" "rds_username" {
  name            = "/umami/rds_username"
  with_decryption = true
}
data "aws_ssm_parameter" "rds_password" {
  name            = "/umami/rds_password"
  with_decryption = true
}
data "aws_ssm_parameter" "grafana_password" {
  name            = "/grafana/password"
  with_decryption = true
}


