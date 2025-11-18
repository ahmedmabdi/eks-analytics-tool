data "aws_ssm_parameter" "rds_username" {
  name            = "/umami/rds_username"
  with_decryption = true
}

data "aws_ssm_parameter" "rds_password" {
  name            = "/umami/rds_password"
  with_decryption = true
}

resource "aws_ssm_parameter" "database_url" {
  name  = "/umami/DATABASE_URL"
  type  = "SecureString"
  value = "postgresql://${urlencode(data.aws_ssm_parameter.rds_username.value)}:${urlencode(data.aws_ssm_parameter.rds_password.value)}@${aws_db_instance.umami.endpoint}/${aws_db_instance.umami.db_name}"
}

resource "kubernetes_secret" "umami_db_secret" {
  metadata {
    name      = "umami-db-secret"
    namespace = "app"
  }

  data = {
    database_url = aws_ssm_parameter.database_url.value
  }

  type = "Opaque"
}

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
