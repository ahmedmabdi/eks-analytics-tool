resource "kubernetes_secret" "umami_db_secret" {
  metadata {
    name      = "umami-db-secret"
    namespace = "umami"
  }

  data = {
    database_url = aws_ssm_parameter.database_url.value
    }

  type = "Opaque"
}