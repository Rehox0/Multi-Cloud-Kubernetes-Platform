<div align="center">
  <h1>Allegro Profit & Margin Analytics on EKS</h1>
  <p>Portfolio project demonstrating production-oriented Kubernetes platform engineering on AWS</p>
</div>

[![AWS](https://custom-icon-badges.demolab.com/badge/AWS-%23FF9900.svg?logo=aws&logoColor=white)](#)
[![Terraform](https://img.shields.io/badge/Terraform-844FBA?logo=terraform&logoColor=fff)](#)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=fff)](#)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)](#)
[![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=fff)](#)
[![ArgoCD](https://img.shields.io/badge/Argocd-EF7B4D?logo=Argo&logoColor=white)](#)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](#)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?logo=prometheus&logoColor=white)](#)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&logoColor=white)](#)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff)](#)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=fff)](#)


## 👁️ Overview
This project focuses on GitOps, security, observability, and operational reliability - the core skill set of a platform/DevOps engineer.

> 🚧 Project actively under development. An Azure-based frontend and multi-cloud
architecture are planned as the next major phase.

---

## ▶️ Live / Demo
> in progress...

---

## 🛠️ Tech Stack
* **Cloud (AWS):** VPC, EKS, ALB, Secrets Manager, IAM, NAT Gateway, VPC Endpoints
* **CI/CD:** ArgoCD, GitHub Actions
* **DevOps:** Terraform, Kubernetes, Docker, Helm, Karpenter, Kyverno, ESO, Cilium, Gateway API
* **Observability:** Prometheus, Grafana, AWS CloudWatch
* **Languages:** Python, Bash

---

## 🏗️ Architecture diagram
- **Infrastructure as Code using Terraform (~100 resources)** - networking, compute, security, scaling, and observability.
- **Remote state** stored in S3 with AES-256 encryption; single `terraform.tfstate` scoped to `eu-north-1`.
- **Security Groups** enforce strict inbound/outbound rules between layers

> in progress...
---

## 🔄 CI/CD
- **ArgoCD (~10 apps):** - Kyverno, Karpenter, ESO, Gateway, Monitoring, Backend, Frontend

> in progress...
---

## ⭐ Code Highlights
> in progress...

---

## ⛔ Problems & Troubleshooting

### Selected challenges
- **Cilium networking:** incorrect `egressMasqueradeInterfaces` configuration
  caused connectivity issues due to interface naming differences between different EC2's.

- **AWS VPC Endpoint + Cilium networking:** IRSA requests to AWS STS were
  timing out because traffic from Kubernetes Pods reached the VPC Endpoint
  with a Security Group that was not allowed by the endpoint's inbound rules.

- **Gateway API:** Cilium initially failed to manage the GatewayClass because
  of an incompatible Gateway API CRD version.

- **Cilium IPAM:** migrating from AWS ENI-based IPAM to Cluster Pool IPAM
  required adjusting Kubernetes pod capacity and node configuration.

- **Karpenter:** dynamically provisioned nodes initially failed to register
  because of an incompatible AMI/user-data configuration.

- **Node stability:** stress testing with a large number of Pods exposed
  resource constraints on `t3.small` nodes, including Cilium endpoint
  creation throttling and kubelet becoming unresponsive.

- **Argo CD / cross-node communication:** switching Cilium from native routing
  to VXLAN tunneling resolved Pod-to-Pod communication issues between nodes.

> 📖 Detailed investigation, diagnostics, root causes and fixes:
> **[Problems & Troubleshooting →](./docs/PROBLEMS.md)**

---

</div>
<div align="center">
  <h1>🚀 Infrastructure Roadmap</h1>
</div>

## Current stage:
![Current stage](./images/EKS_pods.png)

---

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

---

## ✅ Checkbox

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

### 📖 Documentation & Presentation
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

