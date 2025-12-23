output "external_dns_pod_identity_role_arn" {
  value       = module.external_dns_pod_identity.iam_role_arn
}

output "external_dns_pod_identity_name" {
  value       = module.external_dns_pod_identity.iam_role_name
}