resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  create_namespace = true
  namespace        = "nginx-ingress"

  values = [
    file("${path.module}/helm-values/nginx-ingress.yaml")
  ]

  depends_on = [module.eks]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  create_namespace = true
  namespace        = "cert-manager"

  values = [
    file("${path.module}/helm-values/cert-manager.yaml")
  ]

  depends_on = [
    module.cert_manager_pod_identity,
  ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"

  create_namespace = true
  namespace        = "external-dns"

  values = [
    file("${path.module}/helm-values/external-dns.yaml")
  ]

  depends_on = [
    module.external_dns_pod_identity,
  ]
}

resource "helm_release" "argocd_deploy" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.6.1"
  timeout    = 600

  create_namespace = true
  namespace        = "argo-cd"

  values = [
    file("${path.module}/helm-values/argocd.yaml")
  ]

  depends_on = [helm_release.nginx_ingress, helm_release.cert_manager, helm_release.external_dns]


}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.0"

  create_namespace = true
  namespace        = "monitoring"

  values = [
    file("${path.module}/helm-values/monitoring.yaml")
  ]

  depends_on = [helm_release.nginx_ingress, helm_release.cert_manager, helm_release.external_dns]
}

data "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-server"
    namespace = "argo-cd"
  }

  depends_on = [helm_release.argocd_deploy]
}

resource "aws_route53_record" "argocd" {
  zone_id = local.zone_id
  name    = "argocd.ahmedumami.click"
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_ingress_v1.argocd.status[0].load_balancer[0].ingress[0].hostname]
}

