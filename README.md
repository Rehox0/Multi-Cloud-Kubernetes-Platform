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



Current flow:
Jumpbox
  │
  ├── helm install ArgoCD
  │
  ├── git clone
  │
  └── kubectl apply root-app.yaml
              │
              ▼
           ROOT_APP
              │
              ├── apps/kyverno.yaml
              ├── apps/eso.yaml
              ├── apps/...
              │
              ▼
           infra/...


GitOps flow:

eso-operator
    ↓
eso-secret-store
    ↓
eso-backend-secret-dev
    ↓
workload-backend-dev
---
