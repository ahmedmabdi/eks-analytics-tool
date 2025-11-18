data "aws_ssm_parameter" "grafana_password" {
  name = "/grafana/password"
  with_decryption = true
}

resource "kubernetes_secret" "grafana_admin_secret" {
  metadata {
    name      = "grafana-admin-secret"
    namespace = "monitoring"
  }

  data = {
    admin_password = base64encode(data.aws_ssm_parameter.grafana_password.value)
  }

  type = "Opaque"
}
