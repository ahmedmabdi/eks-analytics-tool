# EKS Platform Deployment – Production-Ready AWS Infrastructure

This project provisions a fully managed **Amazon EKS** cluster with end-to-end infrastructure deployed via **Terraform**, containerized app delivery through **ArgoCD** (GitOps), and integrated observability.  
It is designed with a strong focus on **cost-optimization**, security, and operational best practices for production workloads.

---

## Why Amazon EKS?

EKS was chosen for its seamless integration with the AWS ecosystem, managed control plane, and support for Kubernetes-native workflows.  
This solution provides:

- Automated control plane management  
- Secure networking with VPC CNI  
- Integration with IAM for access control  
- Scalability via managed node groups 
- Seamless support for GitOps using ArgoCD  
- Robust monitoring and alerting via Grafana and Prometheus  

---

## Project Highlights

| Feature                     | Description                                                                                  |
|-----------------------------|----------------------------------------------------------------------------------------------|
| **Infrastructure as Code**  | Terraform provisions VPC, EKS cluster, node groups, RDS, ALB, IAM roles, Security Groups      |
| **Networking**              | Public + private subnets spanning 3 AZs; single NAT Gateway to reduce cost without sacrificing access |
| **Database**                | Single-AZ Amazon RDS PostgreSQL instance to balance cost and durability                      |
| **Container Orchestration** | Kubernetes managed by EKS, with GitOps deployments via ArgoCD                                |
| **CI/CD & GitOps**          | Application manifests and Helm charts deployed using ArgoCD, enabling declarative workflows |
| **Monitoring & Logging**    | Prometheus & Grafana integrated for observability               |
| **State Management**        | Terraform state stored in S3 with **native S3 locking** enabled for consistency              |
| **Security & IAM**          | Fine-grained IAM roles and policies applied to cluster components                            |

> **Cost Controls:**  
> - Single NAT Gateway to limit monthly costs while ensuring outbound internet access for private subnets.  
> - Single-AZ RDS instance optimized for development or low-throughput environments.  
> - Minimal node group sizes with auto-scaling for cost efficiency.

---

## Architecture Diagram

![Architecture Diagram](images/architecture.png)  

Key components include:

- VPC with public and private subnets across 3 Availability Zones  
- Managed EKS control plane with worker node groups 
- Single Application Load Balancer (ALB) for ingress traffic  
- Amazon RDS (PostgreSQL) for backend persistence  
- S3 bucket with native locking for Terraform state management  
- ArgoCD deployed in cluster for continuous delivery  
- Monitoring stack: Prometheus + Grafana

---

## Screenshots

### Application UI

![Application Screenshot](media/umamiweb.png)  

### ArgoCD Dashboard

![ArgoCD Screenshot](media/argocd.png)  

### Monitoring Stack (Grafana)

![Monitoring Screenshot](media/grafana1.png) 
![Monitoring Screenshot](media/grafana.png)  
![Monitoring Screenshot](media/prometheus.png)  

---
## Debugging Log
Below is a concise summary of common issues encountered during EKS deployments, their causes, solutions, and key lessons learned for quick reference.

| Issue                         | Cause                                           | Solution                                                      | Lesson Learned                                   |
|-------------------------------|-------------------------------------------------|---------------------------------------------------------------|-------------------------------------------------|
| EKS CNI Not Ready / Addon CREATE_FAILED | Addons installed in wrong order; conflicting CRDs from auto-installed partial CNI | Delete failed addon, remove CRDs, clean leftovers, reinstall addon, recreate nodes | Always install VPC CNI before nodes; use `most_recent = true` for addons |
| Prometheus & Grafana Access Fail | Incorrect ClusterIssuer in ingress; missing DNS records | Fix ingress annotation; update DNS records; reapply Helm chart | Validate TLS issuers and DNS early              |
| Argo CD Service “Not Connected” UI Issue | Visualization limitation—Service selects Pods, no ownerReferences to Deployment | Verified labels & endpoints; no fix needed                    | Use `kubectl get endpoints` to confirm Service routing |
| Certificate Not Issued on EKS | Certificate resource created before Issuer fully reconciled; stale ACME challenges; cert-manager controller delayed reconciliation | Delete stuck CertificateRequest & ACME Challenge, restart cert-manager deployment, monitor Certificate status | Use `depends_on` in Terraform for Certificate → Issuer; split apply stages: cert-manager+Issuer first, then Certificates |


## Future Improvements

- Add **AWS WAF** for web application protection  
- Enable **Multi-AZ RDS** for high availability and failover  
- Integrate **AWS Secrets Manager** for enhanced secret management  
- Add **NAT Gateway in other AZs** for fault tolerance  
- Implement **Security Hub** and **GuardDuty** for advanced security posture monitoring  

---

## CI/CD Workflows

- **Build & Push Container Images**

  ![Build & Push](media/build-push.png)  

- **Terraform Plan & Apply**

  ![Terraform Apply](media/tapply.png)  


---
