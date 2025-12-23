resource "helm_release" "this" {
  name       = var.name
  repository = var.repository
  chart      = var.chart
  
  version = var.chart_version != null ? var.chart_version : null

  create_namespace = true
  namespace        = var.namespace
  timeout          = var.timeout

  values = [
    file(var.values_file)
  ]

}

