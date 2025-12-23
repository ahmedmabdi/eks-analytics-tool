output "cert_manager_pod_identity_role_arn" {
  value       = module.cert_manager_pod_identity.iam_role_arn
}

output "cert_manager_pod_identity_name" {
  value       = module.cert_manager_pod_identity.iam_role_name
}