module "cert_manager_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  name   = "cert-manager"

  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z103935430WUS287YMWJ6"]

  depends_on = [module.eks]

  tags = local.tags
}

module "external_dns_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  name   = "external-dns"

  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z103935430WUS287YMWJ6"]

  depends_on = [module.eks]

  tags = local.tags
}

resource "aws_eks_pod_identity_association" "cert_manager" {
  cluster_name    = local.name
  namespace       = "cert-manager"
  service_account = "cert-manager"
  role_arn        = module.cert_manager_pod_identity.iam_role_arn

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = local.name
  namespace       = "external-dns"
  service_account = "external-dns"
  role_arn        = module.external_dns_pod_identity.iam_role_arn

  depends_on = [
    module.eks,
    module.external_dns_pod_identity,
    helm_release.external_dns
  ]
}

