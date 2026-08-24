<div align="center">
  <h1>Allegro Profit & Margin Analytics on EKS</h1>
  <p>Portfolio project demonstrating production-oriented Kubernetes platform engineering on AWS</p>
</div>

![AWS](https://img.shields.io/badge/AWS-FF9900?logo=amazonaws)
![Terraform Version](https://img.shields.io/badge/Terraform-v1.14.8-7B42BC?logo=terraform)


## Overview | Status
Building to demonstrate production-oriented Kubernetes
Private EKS · Cilium (CNI + Gateway API) · ArgoCD GitOps · Karpenter · Kyverno · ESO + Secrets Manager · Prometheus/Grafana
CI path (build → ECR → auto-sync) still in progress.

## Current stage:
![Current stage](./images/EKS_pods.png)

---

</div>
<div align="center">
  <h1>🚀 Infrastructure Roadmap</h1>
</div>
This project is a standalone, production-oriented Kubernetes platform built on AWS EKS. It focuses on GitOps, security, observability, and operational reliability - the core skill set of a platform/DevOps engineer.

### The infrastructure is managed using:
- EKS + AKS planned in Phase 2
- Terraform
- ArgoCD
- Karpenter
- Kyverno
- Cilium (CNI + Gateway API)
- Helm charts
- Prometheus + Grafana

## 🎯 Final Goal

Provide a production-oriented Kubernetes platform on AWS and Azure demonstrating:

- Infrastructure as Code
- Kubernetes platform engineering
- GitOps end-to-end (build -> registry -> deploy)
- Automated infrastructure scaling
- Cloud-native networking
- Secrets management
- Kubernetes security
- Observability
- High availability
- Failure recovery & disaster recovery
- Cost visibility (FinOps basics)

Multi-cloud (Azure) extension is a future phase, started only after the AWS platform below is fully complete



## ✅ Completed

### ☁️ AWS - Backend
- [x] AWS VPC
- [x] Multi-AZ networking
- [x] Amazon EKS
- [x] Cilium CNI
- [x] Cilium Cluster Pool IPAM
- [x] Cilium Gateway API
- [x] AWS Secrets Manager
- [x] External Secrets Operator
- [x] Karpenter
- [x] ArgoCD
- [x] Kyverno
- [x] Prometheus
- [x] Grafana
- [x] Backend application deployment


### 🔄 CI/CD & GitOps (AWS)

Goal: full path from commit to running pod, no manual image builds/pushes.

- [ ] GitHub Actions — build & test
- [ ] Container image build
- [ ] Push to Amazon ECR
- [ ] Automated image tag update (e.g. ArgoCD Image Updater / GitOps commit step)
- [x] ArgoCD
- [x] GitOps deployment
- [ ] Deployment verification (health checks post-sync)
- [ ] Rollback strategy (ArgoCD rollback / progressive delivery)


### 🔐 Security
- [x] IAM-based AWS access
- [x] AWS Secrets Manager
- [x] External Secrets Operator
- [x] Kyverno
- [x] Kubernetes PriorityClasses
- [ ] Resource requests and limits
- [ ] PodDisruptionBudgets
- [ ] Cilium Network Policies (L3-L7, namespace isolation)
- [ ] Pod Security Standards / restricted profile
- [ ] Image scanning in CI (e.g. Trivy)
- [ ] Kyverno policy expansion (disallow privileged, enforce resource limits, require labels)

### 📊 Observability
- [x] Prometheus
- [x] Grafana
- [x] Alertmanager
- [x] kube-state-metrics
- [x] Node Exporter
- [x] Kubernetes dashboards
- [ ] Application-level metrics (custom exporters / business KPIs)
- [ ] Centralized logging (e.g. Loki or CloudWatch Logs)
- [ ] Distributed tracing (basic, e.g. OpenTelemetry + Tempo)
- [ ] SLO-based alerting rules

### 💰 Cost Visibility (FinOps basics)
- [ ] Cost allocation tags across resources
- [ ] Karpenter cost-aware provisioning notes (spot vs on-demand mix)
- [ ] Basic cost dashboard / report (e.g. Kubecost or AWS Cost Explorer tagging)
- [ ] Documented cost trade-offs in README

### 🧪 Reliability & Disaster Recovery
- [x] Pod failure testing
- [x] Node failure testing
- [x] Karpenter scale-up testing
- [x] Karpenter scale-down testing
- [x] Workload rescheduling
- [ ] Database backup and restore testing
- [ ] Disaster recovery procedure (documented runbook)
- [ ] RTO definition
- [ ] RPO definition

### 📖 Documentation & Presentation (before moving on)
- [ ] Architecture diagram (current AWS-only state)
- [ ] README: design decisions and trade-offs (why Cilium, why Karpenter, why Kyverno)
- [ ] README: known limitations / what's intentionally not done yet
- [ ] Short demo video (deploy flow: commit → CI → ArgoCD sync → running pod)


## 🌐 Phase 2 - Multi-Cloud Extension (Azure)

This phase is explicitly a learning/demonstration extension - documented as such in the README to preempt "why multi-cloud for this workload?" questions.

### Azure - Frontend Platform
- [ ] Azure networking
- [ ] Azure resource groups
- [ ] Azure AKS / frontend compute platform
- [ ] Frontend container deployment
- [ ] Azure Container Registry
- [ ] Frontend CI/CD
- [ ] Azure ingress
- [ ] HTTPS / TLS
- [ ] Azure monitoring

---

- [ ] Multi-Cloud Connectivity
- [ ] Multi-Cloud Security
- [ ] Multi-Cloud Observability
- [ ] Multi-Cloud Reliability

