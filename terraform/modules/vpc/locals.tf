locals {
  name        = "eks-cluster"
  domain      = "ahmedumami.click"
  region      = "eu-west-2"
  hosted_zone = "arn:aws:route53:::hostedzone/Z103935430WUS287YMWJ6"
  zone_id     = "Z103935430WUS287YMWJ6"


  tags = {
    project = "EKS PROJECT"
    owner   = "Ahmed"
  }
}