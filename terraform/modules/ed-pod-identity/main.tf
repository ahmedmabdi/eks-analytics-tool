module "external_dns_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  name   = "external-dns"

  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z103935430WUS287YMWJ6"]


  tags = local.tags
}
resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = local.name
  namespace       = "external-dns"
  service_account = "external-dns"
  role_arn        = module.external_dns_pod_identity.iam_role_arn

 depends_on = [ module.external_dns_pod_identity ]
}