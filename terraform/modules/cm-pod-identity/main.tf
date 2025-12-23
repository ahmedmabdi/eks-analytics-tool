module "cert_manager_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  name   = "cert-manager"

  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z103935430WUS287YMWJ6"]


  tags = local.tags
}


resource "aws_eks_pod_identity_association" "cert_manager" {
  cluster_name    = local.name
  namespace       = "cert-manager"
  service_account = "cert-manager"
  role_arn        = module.cert_manager_pod_identity.iam_role_arn

 depends_on = [ module.cert_manager_pod_identity ]
}
