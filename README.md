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


NAME                                         STATUS   ROLES    AGE     VERSION               INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION           CONTAINER-RUNTIME
ip-10-0-10-212.eu-north-1.compute.internal   Ready    <none>   175m    v1.35.6-eks-254016e   10.0.10.212   <none>        Amazon Linux 2023.12.20260803   6.12.95-124.187.amzn2023.x86_64   containerd://2.2.5+unknown
ip-10-0-11-190.eu-north-1.compute.internal   Ready    <none>   5h52m   v1.35.6-eks-254016e   10.0.11.190   <none>        Amazon Linux 2023.12.20260803   6.12.95-124.187.amzn2023.x86_64   containerd://2.2.5+unknown
ip-10-0-12-205.eu-north-1.compute.internal   Ready    <none>   5h52m   v1.35.6-eks-254016e   10.0.12.205   <none>        Amazon Linux 2023.12.20260803   6.12.95-124.187.amzn2023.x86_64   containerd://2.2.5+unknown
NAMESPACE          NAME                                                             READY   STATUS    RESTARTS        AGE
argocd             argocd-application-controller-0                                  1/1     Running   0               174m
argocd             argocd-applicationset-controller-6c5ff85d8b-25r89                1/1     Running   0               3h37m
argocd             argocd-dex-server-788b88d944-5rfkk                               1/1     Running   0               3h37m
argocd             argocd-notifications-controller-764589f448-z9pcp                 1/1     Running   0               4h1m
argocd             argocd-redis-789f67fd7c-xtfw7                                    1/1     Running   0               3h45m
argocd             argocd-repo-server-cb4df4677-qws6b                               1/1     Running   1 (3h43m ago)   3h45m
argocd             argocd-server-8999cdcb8-nnz7c                                    1/1     Running   0               3h37m
backend-ns         workload-backend-dev-fc54fffd7-hmrz8                             1/1     Running   0               3h37m
backend-ns         workload-backend-dev-fc54fffd7-tzh6t                             1/1     Running   0               3h37m
backend-ns         workload-backend-dev-fc54fffd7-zjdzw                             1/1     Running   0               4h
external-secrets   eso-operator-external-secrets-77fb5d77d6-l2rhc                   1/1     Running   0               3h37m
external-secrets   eso-operator-external-secrets-cert-controller-7d69f4797b-r8nsp   1/1     Running   0               3h37m
external-secrets   eso-operator-external-secrets-webhook-55bb47bf94-hrxjm           1/1     Running   0               3h37m
frontend-ns        workload-frontend-dev-567f795cb9-bfzh7                           1/1     Running   0               4h
karpenter          karpenter-86cbfcc667-957kt                                       1/1     Running   0               3h37m
karpenter          karpenter-86cbfcc667-hx5pj                                       1/1     Running   0               4h
kube-system        cilium-d2wds                                                     1/1     Running   0               5h50m
kube-system        cilium-dm55p                                                     1/1     Running   0               5h50m
kube-system        cilium-envoy-g829c                                               1/1     Running   0               5h50m
kube-system        cilium-envoy-l4dlt                                               1/1     Running   0               175m
kube-system        cilium-envoy-s4f8k                                               1/1     Running   0               5h50m
kube-system        cilium-operator-c4d499ddd-2wzxq                                  1/1     Running   0               3h37m
kube-system        cilium-operator-c4d499ddd-cz9gw                                  1/1     Running   0               5h50m
kube-system        cilium-xmbsf                                                     1/1     Running   0               175m
kube-system        coredns-66559c7c49-smpcl                                         1/1     Running   0               4h2m
kube-system        coredns-66559c7c49-ttgcn                                         1/1     Running   0               3h37m
kyverno            kyverno-admission-controller-86855869d5-hr2mb                    1/1     Running   0               4h
kyverno            kyverno-background-controller-8fb8b68cf-gt5nq                    1/1     Running   0               4h
kyverno            kyverno-cleanup-controller-fdcbbd468-6cc8d                       1/1     Running   0               3h45m
kyverno            kyverno-reports-controller-7949866bf7-lthc6                      1/1     Running   0               3h37m
monitoring         alertmanager-kube-prometheus-stack-alertmanager-0                2/2     Running   0               174m
monitoring         kube-prometheus-stack-grafana-677d5fc94b-48spq                   3/3     Running   0               173m
monitoring         kube-prometheus-stack-kube-state-metrics-869857b4d7-fmrl9        1/1     Running   0               3h59m
monitoring         kube-prometheus-stack-operator-7bcd6567d9-lgg7l                  1/1     Running   0               3h59m
monitoring         kube-prometheus-stack-prometheus-node-exporter-48b94             1/1     Running   1 (3h43m ago)   3h59m
monitoring         kube-prometheus-stack-prometheus-node-exporter-sqqg5             1/1     Running   0               175m
monitoring         kube-prometheus-stack-prometheus-node-exporter-xjdrp             1/1     Running   0               3h59m
monitoring         prometheus-kube-prometheus-stack-prometheus-0                    2/2     Running   0               3h59m
NAME                    SYNC STATUS   HEALTH STATUS
backend-identity        Synced        Healthy
eso-backend-secret      Synced        Healthy
gateway                 Synced        Healthy
karpenter               Synced        Healthy
karpenter-config        Synced        Healthy
kube-prometheus-stack   Synced        Healthy
kyverno-policies        Synced        Healthy
kyverno-system          Synced        Healthy
root-app                Synced        Healthy
workload-backend-dev    Synced        Healthy
workload-frontend-dev   Synced        Healthy
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    OK
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

DaemonSet              cilium                   Desired: 3, Ready: 3/3, Available: 3/3
DaemonSet              cilium-envoy             Desired: 3, Ready: 3/3, Available: 3/3
Deployment             cilium-operator          Desired: 2, Ready: 2/2, Available: 2/2
Containers:            cilium                   Running: 3
                       cilium-envoy             Running: 3
                       cilium-operator          Running: 2
                       clustermesh-apiserver
                       hubble-relay
Cluster Pods:          25/25 managed by Cilium
Helm chart version:    1.20.0
Image versions         cilium             quay.io/cilium/cilium:v1.20.0@sha256:383968cd5e8873f7976fa76aa6196045643558f4cc9518a207b9335cb24a0e93: 3
                       cilium-envoy       quay.io/cilium/cilium-envoy:v1.37.5-1782911245-7cffc778c923f68a77954a53b1a98d6b5353f004@sha256:583057dd4f7d54cd41efff3c413aa0b148ac201f522e2c3336851fa89c78b039: 3
                       cilium-operator    quay.io/cilium/operator-generic:v1.20.0@sha256:80744a8cc7c91c2f9e6347629406844eb35d79b30a732c6d41c15b17232a74f3: 2
NAME                                         CILIUMINTERNALIP   INTERNALIP    AGE
ip-10-0-10-212.eu-north-1.compute.internal   10.244.3.173       10.0.10.212   175m
ip-10-0-11-190.eu-north-1.compute.internal   10.244.0.117       10.0.11.190   5h50m
ip-10-0-12-205.eu-north-1.compute.internal   10.244.1.8         10.0.12.205   5h50m
---
