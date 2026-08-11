<div align="center">
  <h1>Allegro Profit & Margin Analytics on EKS</h1>
  <p>Portfolio project demonstrating hands-on experience with EKS</p>
</div>

## Overview
Building to gain hands-on experience with:

- EKS + Terraform
- ArgoCD
- Prometheus + Grafana
- Karpenter
- Kyverno
- Helm charts
- IRSA (IAM Roles for Service Accounts)


GitOps goal:

                        Argo CD
                           │
                           ▼
                    ┌─────────────┐
                    │ root-app    │
                    └──────┬──────┘
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
      ┌─────────────┐             different components
      │ eso-operator│             
      └──────┬──────┘
             │
             │ Healthy
             ▼
      ┌──────────────┐
      │ ESO dependency│
      │  gate(backend)│
      └──────┬───────┘
             │
             │ unlock
             ▼
      ┌─────────────────┐
      │eso-secret-storage│
      └────────┬────────┘
               │
               │ ClusterSecretStore Ready
               ▼
      ┌─────────────────┐
      │ ExternalSecret  │
      └────────┬────────┘
               │
               │ SecretSynced
               ▼
           backend
---
