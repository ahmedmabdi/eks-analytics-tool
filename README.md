 # Web Analytics Application on Amazon EKS

## Introduction
This project deploys a containerised web analytics application (Umami) on Amazon EKS using a production-aligned cloud-native architecture. It uses Terraform for provisioning, Helm for deployment, and ArgoCD for GitOps automation. The environment includes secure networking, managed Kubernetes control plane, scalable node groups, and AWS-integrated IAM, DNS, certificates, logging, and monitoring.

## Project Overview
This repository provisions the full infrastructure and application stack required for running Umami on EKS. Terraform handles VPC, EKS, RDS, IAM, and Pod Identity. Kubernetes add-ons (Ingress, certificates, DNS, monitoring, GitOps) are deployed via Helm and ArgoCD. GitHub Actions provides CI/CD for container builds and Terraform deployment.

### Core Tools
- Terraform (AWS infrastructure)
- Docker (application container)
- Helm (Kubernetes components)
- ArgoCD (GitOps)
- GitHub Actions (CI/CD)
- AWS Pod Identity
- SSM Parameter Store

### Kubernetes Add-ons
- NGINX Ingress Controller  
- cert-manager  
- ExternalDNS  
- ArgoCD  
- Prometheus  
- Grafana  

### Application Components
- Umami Docker image  
- PostgreSQL RDS instance  
- Helm values for each add-on  
- ArgoCD applications for automated deployment  

## Architecture Summary
The platform uses a multi-AZ VPC with public and private subnets, a managed EKS cluster, private RDS PostgreSQL, and Kubernetes add-ons for networking, security, and observability. Traffic enters through an Ingress Controller, services authenticate using AWS Pod Identity, and secrets are stored in SSM Parameter Store. Terraform manages all AWS components while ArgoCD continuously deploys application manifests.

### Networking (VPC)
- CIDR: 10.0.0.0/16  
- Three private and three public subnets  
- One NAT gateway  
- DNS hostnames + DNS support enabled  

### EKS Cluster
- Kubernetes 1.30  
- Managed node group (t3.medium, multi-AZ)  
- Worker nodes in private subnets  
- Core add-ons: CoreDNS, kube-proxy, VPC CNI, Pod Identity Agent  

### Database Layer (RDS)
- PostgreSQL in private subnets  
- Credentials stored in SSM Parameter Store  
- Application retrieves credentials through environment variables  

## GitOps and CI/CD
Docker images are built and pushed to ECR using GitHub Actions. Terraform deployments run through a separate pipeline using GitHub OIDC authentication. ArgoCD monitors the repository and syncs manifests automatically, eliminating the need for manual kubectl commands.

## Repository Structure
```
.github/workflows/
app/
helm-values/
manifests/
media/
eks.tf
helm.tf
locals.tf
podidentity.tf
providers.tf
rds.tf
vpc.tf
README.md
```

## CI/CD Overview
The build pipeline creates container images and pushes them to ECR. The Terraform pipeline initialises, plans, and applies infrastructure changes using remote state in S3 and DynamoDB locking. ArgoCD consumes the manifests and deploys changes automatically to the cluster.

## Troubleshooting (Headings Only)
- CRD Conflicts  
- EKS Add-on Failures  
- Node Not Ready  
- SSM Parameter Errors  
- VPC Deletion Blocked by ENIs  
- Pod Identity Role Issues  
- Ingress or DNS Misconfiguration  
- RDS Connectivity  

## Future Improvements
This platform can be extended with multi-node-group autoscaling, multi-AZ HA RDS, KMS encryption, private EKS API endpoint, network policies, NLB ingress, cluster autoscaler, Velero backups, and cost-optimisation using Graviton and subnet-aware autoscaling.