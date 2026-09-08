<div align="center">
  <h1>Multi-Cloud Kubernetes Platform</h1>
  <p>Portfolio project demonstrating production-oriented Kubernetes platform engineering on AWS and Azure</p>
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
- **Infrastructure as Code using Terraform (+100 resources)** - networking, compute, security, scaling, and observability.
- **Remote state** stored in S3 with AES-256 encryption; single `terraform.tfstate` scoped to `eu-north-1`.
- **Security Groups** enforce strict inbound/outbound rules between layers

> in progress...
---

## 🔄 CI/CD
- **ArgoCD (~10 apps):** - Kyverno, Karpenter, ESO, Gateway, Monitoring, Backend, Frontend
- **Frontend:** - GitHub ➔ CI ➔ Docker ➔ ECR ➔ update Helm ➔ ArgoCD ➔ EKS
- **Backend:** - GitHub ➔ CI ➔ tests ➔ Docker ➔ ECR ➔ update Helm ➔ ArgoCD ➔ EKS
- **Rollback:** - ⛔Failed deployment ➔ ⛔degraded Pod + healthy replicas✅ ➔ Git revert ➔ ArgoCD reconciliation ➔ recovery
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
> **[Problems & Troubleshooting →](./docs/troubleshooting.md)**

---

## 💰 Cost Visibility

- **Cost allocation:** Terraform applies Project, Environment and ManagedBy tags for AWS cost tracking.
- **Karpenter:** dynamic node provisioning reduces idle capacity; Spot can be used for fault-tolerant workloads.
- **Cost monitoring:** AWS Cost Explorer with project/environment tags.
- **Trade-offs:** Karpenter uses smaller instances t3.small, while core nodes uses bigger m7i-flex.large

---

</div>
<div align="center">
  <h1>🚀 Infrastructure Roadmap</h1>
</div>

## Current stage:
### AWS
![Current stage](./images/EKS_pods.png)
### Azure
<details>
<summary><b>🔍 Click to expand <code>kubectl get pods -A</code> output</b></summary>

```bash
NAMESPACE          NAME                                                             READY   STATUS      RESTARTS        AGE
argocd             argocd-application-controller-0                                  1/1     Running     0               7h25m
argocd             argocd-applicationset-controller-67c694bc9b-mwzx4                1/1     Running     0               7h25m
argocd             argocd-dex-server-68d7788bd9-jf7tw                               1/1     Running     0               7h25m
argocd             argocd-notifications-controller-f7d5569db-dblhg                  1/1     Running     0               7h25m
argocd             argocd-redis-7d7468d598-2xt2g                                    1/1     Running     0               7h25m
argocd             argocd-repo-server-698564b7cc-88dt4                              1/1     Running     0               7h25m
argocd             argocd-server-7b7f6749c5-jlkmm                                   1/1     Running     0               7h25m
backend-ns         azure-workload-backend-dev-5b897659c-7rwdt                       1/1     Running     0               7h7m
backend-ns         azure-workload-backend-dev-5b897659c-g4pv4                       1/1     Running     0               7h7m
backend-ns         azure-workload-backend-dev-5b897659c-tbqng                       1/1     Running     0               7h7m
backend-ns         azure-workload-backend-dev-5b897659c-xrt2b                       1/1     Running     0               7h7m
external-secrets   eso-operator-external-secrets-58784cb564-ptjvj                   1/1     Running     0               7h25m
external-secrets   eso-operator-external-secrets-cert-controller-78698b6b8b-mv5v4   1/1     Running     0               7h25m
external-secrets   eso-operator-external-secrets-webhook-6cf46fc9d4-krqcm           1/1     Running     0               7h25m
frontend-ns        azure-workload-frontend-dev-797cb6f4c4-bmjzx                     1/1     Running     0               7h8m
frontend-ns        azure-workload-frontend-dev-797cb6f4c4-qmr4g                     1/1     Running     0               7h8m
frontend-ns        azure-workload-frontend-dev-797cb6f4c4-z5tz8                     1/1     Running     0               7h8m
kube-system        azure-wi-webhook-controller-manager-6c8f8bb644-5xb8g             1/1     Running     2 (7h26m ago)   7h29m
kube-system        azure-wi-webhook-controller-manager-6c8f8bb644-csgws             1/1     Running     2 (7h26m ago)   7h29m
kube-system        cilium-4lwhb                                                     1/1     Running     0               7h26m
kube-system        cilium-b9d6v                                                     1/1     Running     0               7h26m
kube-system        cilium-envoy-5k7mt                                               1/1     Running     0               7h26m
kube-system        cilium-envoy-dfffs                                               1/1     Running     0               7h26m
kube-system        cilium-operator-67b647f48c-gx9h5                                 1/1     Running     0               7h26m
kube-system        cilium-operator-67b647f48c-qwffg                                 1/1     Running     0               7h26m
kube-system        cloud-node-manager-brzp6                                         1/1     Running     0               7h48m
kube-system        cloud-node-manager-sx74f                                         1/1     Running     0               7h48m
kube-system        coredns-5d474ff6db-kt8ct                                         1/1     Running     0               7h26m
kube-system        coredns-5d474ff6db-xzwqz                                         1/1     Running     0               7h50m
kube-system        coredns-autoscaler-6769f8f9b-kmgt5                               1/1     Running     0               7h50m
kube-system        csi-azuredisk-node-8j8vm                                         3/3     Running     0               7h48m
kube-system        csi-azuredisk-node-c864x                                         3/3     Running     0               7h48m
kube-system        csi-azurefile-node-h48x4                                         4/4     Running     0               7h48m
kube-system        csi-azurefile-node-qqw4t                                         4/4     Running     0               7h48m
kube-system        konnectivity-agent-autoscaler-7c54b597d4-jfwzn                   1/1     Running     0               7h50m
kube-system        konnectivity-agent-d678f8f46-xzg7h                               1/1     Running     0               7h40m
kube-system        konnectivity-agent-d678f8f46-zfhm7                               1/1     Running     0               7h26m
kube-system        metrics-server-5b879b45fc-chh7t                                  2/2     Running     0               7h23m
kube-system        metrics-server-5b879b45fc-tdc9p                                  2/2     Running     0               7h23m
kyverno            kyverno-admission-controller-86855869d5-s9g5c                    1/1     Running     0               7h8m
kyverno            kyverno-background-controller-8fb8b68cf-cks96                    1/1     Running     0               7h8m
kyverno            kyverno-cleanup-controller-fdcbbd468-pnrb5                       1/1     Running     0               7h8m
kyverno            kyverno-reports-controller-7949866bf7-5k7fc                      1/1     Running     0               7h8m
kyverno            kyverno-system-migrate-resources-hzhkb                           0/1     Completed   0               5h43m
monitoring         alertmanager-kube-prometheus-stack-alertmanager-0                2/2     Running     0               7h7m
monitoring         kube-prometheus-stack-grafana-849c9db65d-2795h                   3/3     Running     0               3h22m
monitoring         kube-prometheus-stack-kube-state-metrics-869857b4d7-jhbgn        1/1     Running     0               7h8m
monitoring         kube-prometheus-stack-operator-7bcd6567d9-p5hf4                  1/1     Running     0               7h8m
monitoring         kube-prometheus-stack-prometheus-node-exporter-8rb8z             1/1     Running     0               7h8m
monitoring         kube-prometheus-stack-prometheus-node-exporter-jsgxw             1/1     Running     0               7h8m
monitoring         prometheus-kube-prometheus-stack-prometheus-0                    2/2     Running     0               7h7m
```
</details>
---

## ✅ Checkbox

### ☁️ AWS
- [x] AWS VPC
- [x] S3 remote state
- [x] Amazon EKS
- [x] Multi-AZ networking
- [x] Cilium CNI
- [x] Cilium Cluster Pool IPAM
- [x] Cilium Gateway API
- [x] AWS Secrets Manager
- [x] ECR
- [ ] CloudFront


### 🔄 CI/CD & GitOps (AWS)
- [x] GitHub Actions - build & test
- [x] Container image build
- [x] Push to Amazon ECR
- [x] Automated image tag update
- [x] ArgoCD
- [x] GitOps deployment
- [x] Deployment health monitoring via ArgoCD
- [x] Rollback strategy and recovery testing


### 🔐 Security
- [x] Kyverno
- [x] External Secrets Operator
- [x] IAM-based AWS access
- [x] Kubernetes PriorityClasses
- [x] Resource requests and limits
- [x] PodDisruptionBudgets
- [x] Cilium Network Policies (L3-L7, namespace isolation)
- [x] Pod Security Standards / restricted profile
- [x] Image scanning in CI (e.g. Trivy)
- [x] Kyverno policy expansion:
-- [x] Disallow privileged containers
-- [x] Enforce resource requests and limits
-- [x] Require mandatory labels

### 📊 Observability
- [x] Prometheus
- [x] Grafana
- [x] Alertmanager
- [x] kube-state-metrics
- [x] Node Exporter
- [x] Kubernetes dashboards
- [x] Application-level metrics
- [ ] Alerting
- [ ] Centralized logging ELK Stack

### 💰 Cost Visibility
- [x] Cost allocation tags across resources
- [x] Karpenter cost-aware provisioning notes (spot vs on-demand mix)
- [x] Documented cost trade-offs in README

### 🧪 Reliability & Disaster Recovery
- [x] Karpenter
- [x] Karpenter scale-up testing
- [x] Karpenter scale-down testing
- [x] Pod failure testing
- [x] Node failure testing
- [x] Workload rescheduling
- [ ] Database backup and restore testing
- [ ] Disaster recovery procedure (documented runbook)
- [ ] RTO definition
- [ ] RPO definition

### 📖 Documentation & Presentation
- [ ] Architecture diagram
- [ ] README: design decisions and trade-offs (why Cilium, why Karpenter, why Kyverno)
- [ ] README: known limitations / what's intentionally not done yet
- [ ] Short demo video (deploy flow: commit → CI → ArgoCD sync → running pod)
- [ ] Clean code


## 🌐 Phase 2 - Multi-Cloud Extension (Azure)

This phase is explicitly a learning/demonstration extension - documented as such in the README to preempt "why multi-cloud for this workload?" questions.

### Azure
- [x] Azure AKS
- [x] Management/jumpbox
- [x] Cilium CNI
- [x] Azure networking
- [x] Azure Container Registry
- [x] Frontend CI
- [x] Frontend CD
- [x] Backend CI
- [x] Backend CD
- [x] Azure Front Door
- [ ] Azure monitoring

- [ ] Multi-Cloud Connectivity
- [x] Azure Traffic Manager
- [ ] Azure Multicloud Interconnect
- [ ] AWS Interconnect
- [ ] Multi-Cloud Security
- [ ] Multi-Cloud Observability
- [ ] Multi-Cloud Reliability

