# Troubleshooting & Engineering Challenges

This document records the main technical problems encountered while building
and operating the Kubernetes platform.

It focuses on issues that required non-trivial investigation, root-cause analysis, or architectural changes.

Each entry documents the symptoms, investigation path, root cause, resolution or relevant engineering lessons.

Minor configuration issues and routine Terraform errors are intentionally omitted.

## Table of Contents

1. [Terraform apply + Cluster in Private Subnets](#1-terraform-apply--cluster-in-private-subnets)
2. [Cilium Egress Masquerading Interface](#2-cilium-egress-masquerading-interface)
3. [ArgoCD / ESO - AWS SG connectivity](#3-argocd--eso---aws-sg-connectivity)
4. [Pod IP Exhaustion on t3.small Nodes](#4-pod-ip-exhaustion-on-t3small-nodes)
5. [Gateway API CRD Version Mismatch](#5-gateway-api-crd-version-mismatch)
6. [Frontend → Backend Traffic Blocked](#6-frontend--backend-traffic-blocked)
7. [Cluster Pool IPAM Migration](#7-cluster-pool-ipam-migration)
8. [ArgoCD Repo-Server Cross-Node Networking](#8-argocd-repo-server-cross-node-networking)
9. [Karpenter Nodes Not Registering](#9-karpenter-nodes-not-registering)
10. [Stress Test: kubelet Unresponsive](#10-stress-test-kubelet-unresponsive)
11. [Node Randomly Going NotReady](#11-node-randomly-going-notready)
12. [CoreDNS Pods Stuck NotReady](#12-coredns-pods-stuck-notready)
13. [GitHub Actions OIDC: "Not authorized to assume role"](#13-github-actions-oidc-not-authorized-to-assume-role)
14. [TargetGroupBinding: Health Checks Failing](#14-targetgroupbinding-health-checks-failing)

## 1. Terraform apply + Cluster in Private Subnets
### Problem
Terraform was unable to install/configure Kubernetes and Helm resources during
the initial `terraform apply`. The Kubernetes API and workloads were running in
private subnets, while Terraform executed from outside the VPC (no direct
connectivity to the API server).

### Root Cause
Bootstrap resources (Kubernetes provider / Helm) required network reachability
to the private API endpoint that was not available during the initial apply.

### Resolution
Kubernetes/Helm resources were separated from the initial Terraform bootstrap
and later moved to ArgoCD/GitOps management.

### Lesson Learned
Infrastructure provisioning and Kubernetes application/platform management have
different networking and lifecycle requirements.

## 2. Cilium Egress Masquerading Interface
### Problem
Cilium networking was not behaving as expected after enabling native routing.

### Root Cause
The configured `egressMasqueradeInterfaces` did not match the actual network
interface used by the EC2 nodes.

Assumed interface pattern: `ens+`
Actual interface: `enp39s0`

### Lesson Learned
Never assume Linux network interface naming. Verify the actual interface with
`ip route`, `ip addr`, or `ip link` before configuring CNI networking.

## 3. ArgoCD / ESO - AWS SG connectivity
### Problem
External Secrets Operator could not obtain AWS credentials through IRSA.
ArgoCD reported an invalid provider configuration. 

### Investigation
**Error Log:**
```
failed to refresh cached credentials, failed to retrieve credentials, operation error STS: AssumeRoleWithWebIdentity, exceeded maximum number of attempts, 3, https response error StatusCode: 0, RequestID: , request send failed, Post "https://sts.eu-north-1.amazonaws.com/": dial tcp 10.0.12.31:443: i/o timeout
```
Worked backward from the API server down to the webhook to rule out a cert/TLS problem first:
```
kube-apiserver ➔ webhook ❌
DNS                      ✅
K8s Service              ✅
Endpoints                ✅
TLS handshake            ✅

webhook:
  cert SAN               ✅
  CA                     ✅
  Secret                 ✅
  Deployment             ✅
  Endpoint               ✅
  response               ✅

Service name             ✅
Namespace                ✅
Endpoint response        ✅
client -> webhook        ✅
TCP                      ✅

kube-apiserver -> Service external-secrets-operator-webhook -> Pod external-secrets-webhook  ✅
diff ca.crt webhook-ca.crt  ✅
```
Webhook path was clean, so the problem had to be further out - on the STS/VPC Endpoint path:

```
✅ ClusterIP
✅ kube-proxy/Cilium routing
✅ DNS & endpoint STS
❌ TCP 443 ➔ VPC Endpoint
```
Checked the endpoint's Security Group inbound rules against what traffic actually looked like:
```
VPC Endpoint ENI SG:
  10.0.10.171 -> sg-03ee5f8c0790c08ba
  10.0.11.238 -> sg-03ee5f8c0790c08ba
  10.0.12.31  -> sg-03ee5f8c0790c08ba


Endpoint SG ingress allows:
  sg-02e1fb4ec9295872c  (nodes)
  sg-0a9108dda1e42ce13  (cilium)


Actual pod traffic arrives as:
  sg-085e462b302b47fca  (EKS cluster/pod traffic)  ❌ not in the allow list


VPC Endpoint SG
      |
      +-- sg-02e1fb4ec9295872c  (nodes)
      |
      +-- sg-0a9108dda1e42ce13  (Cilium ENI)
      |
      +-- sg-085e462b302b47fca  (EKS cluster/pod traffic)


Connection timed out: Pod & Node (curl -v --connect-timeout 5 https://sts.eu-north-1.amazonaws.com) ❌
NetworkPolicy               ✅
Cilium policy               ✅
kube-proxy replacement      ✅
BPF routing                 ✅
NACL inbound & outbound [*] ✅
route tables                ✅
```
NetworkPolicy, Cilium policy, kube-proxy replacement and BPF routing were all fine, so the last check
was VPC Flow Logs on the endpoint ENI:
```
@timestamp                srcAddr       dstAddr      srcPort  dstPort  protocol  action   logStatus
2026-08-07T16:33:07.000Z  10.0.10.201   10.0.12.31   42838    443      6         REJECT   OK
2026-08-07T16:30:47.000Z  10.0.10.121   10.0.12.31   47078    443      6         REJECT   OK
```
Confirmed: traffic was being REJECTED at the endpoint ENI, matching the SG mismatch above.

### Root Cause
Pods send traffic directly from their own IPs, so packets arriving at the VPC Endpoint ENI carry the
Security Group attached to pod/cluster traffic (`sg-085e462b302b47fca`). The Security Group on the STS
VPC Endpoints (`sg-03ee5f8c0790c08ba`) had no inbound rule allowing traffic from that SG.

### Resolution
Added an inbound rule on the endpoint's Security Group allowing port 443 from `sg-085e462b302b47fca`.

---

## 4. Pod IP Exhaustion on t3.small Nodes
### Problem
EKS nodes stopped accepting new pods, logging IP allocation failures.

### Root Cause
`t3.small` provides limited ENI/IP capacity (3 ENIs × 4 IPs = 12 IPs)
This resulted in approximately 11 usable pod IPs per node.

### Resolution
Because vertical scaling was constrained by AWS Free Tier limits, the cluster was scaled horizontally by adding more `t3.small` nodes.

## 5. Gateway API CRD Version Mismatch
### Problem
Cilium logged `enable-gateway-api=true` and recognized the `GatewayClass` resource, but failed to process or own it.

### Investigation
```
enable-gateway-api=true in Cilium         ✅
Cilium takes ownership                    ❌
Cilium sees GatewayClass                  ✅
Cilium Operator 2/2                       ✅
Gateway API CRD                           ✅
ClusterRole                               ✅
ClusterRoleBinding                        ✅
SA                                        ✅
RBAC                                      ✅
controllerName: io.cilium/gateway-controller ✅
```

Restarting Cilium (documented fix) did not help. Inspected Cilium Operator logs and found validation errors:

```
mismatch version Gateway API CRD -> Cilium 1.17.4. ❌
status.supportedFeatures[0]: Invalid value: "object":
supportedFeatures[0] in body must be of type string: "object"
Duplicate value: {}
```
### Root Cause
Version mismatch between Gateway API CRDs and Cilium 1.17.4  
(Cilium 1.17.4 supports Gateway API up to v1.6.1).

### Resolution
Installed the exact matching CRD version supported by Cilium 1.17.4.

## 6. Frontend → Backend Traffic Blocked
### Problem
`HTTPRoute` was configured correctly, but frontend pods could not reach backend pods.

### Root Cause
Default Cilium configuration applies a **deny-all** policy at L3/L4 when network policies are active. An explicit NetworkPolicy permitting ingress traffic from the frontend namespace/pods to backend pods was missing.

### Resolution
Created a NetworkPolicy allowing ingress traffic on backend target ports originating from frontend pod labels.

## 7. Cluster Pool IPAM Migration
### Problem
Switching IPAM from AWS ENI-based to Cluster Pool meant pod capacity per node was no longer tied to
ENI/IP hardware limits (for t3.small: 3 ENI * 4 IP = 12 IPs -> max 11 pods).

### Resolution & Risk
`kubelet --max-pods` must be set explicitly (e.g. 11). While Cluster Pool allows bypassing ENI limits, artificially inflating `--max-pods` on small instances **without** adjusting Kubelet resource reservations directly leads to OOM and node failures *(see issues #10 and #11)*

### Lesson Learned
Removing an artificial capacity limit (ENI) does not magically increase real
node capacity. Always keep `--max-pods`, `--kube-reserved` and
`--system-reserved` aligned with the actual instance size.
      
## 8. ArgoCD Repo-Server Cross-Node Networking
### Problem
Pod-to-pod traffic between ArgoCD components on different nodes was silently failing.

### Investigation
ArgoCD components scheduled on the same node communicated correctly, while communication between components scheduled on different nodes failed.

This isolated the problem to the cross-node pod networking path rather than ArgoCD itself.
Testing pod connectivity by node placement confirmed that the failure was dependent on the underlying Cilium routing mode.

### Root Cause
Native routing was unable to provide reliable cross-node pod connectivity with the current Cilium/AWS networking configuration.

### Resolution
Switched Cilium from native routing to VXLAN tunnel mode.

VXLAN encapsulates pod traffic inside UDP traffic between node IPs, avoiding the failing native-routing path.

## 9. Karpenter Nodes Not Registering
### Problem
Karpenter provisioned nodes successfully, but they never joined the EKS cluster.

**Error Log (Node level)**
```
cloud-init: Unhandled unknown content-type (application/node.eks.aws) userdata
```

### Root Cause 
The provisioned AMI was not compatible with the userdata format Karpenter was sending. Switching to a compatible EKS-optimized AMI fixed registration.

## 10. Stress Test: kubelet Unresponsive
### Problem
Deploying 30 pods simultaneously on `t3.small` nodes triggered Cilium's endpoint-creation rate limit (`429 TooManyRequests` / `putEndpointIdTooManyRequests`). During the burst, 2 out of 3 nodes flipped to `NotReady`.

### Root Cause
The sudden burst of pod creation overloaded both Cilium and the under-provisioned nodes. Combined with missing hard resource reservations (see #11), the nodes could not handle the load gracefully.

*This incident exposed a deeper node-sizing and kubelet configuration problem later confirmed in issue #11.*

## 11. Node Randomly Going NotReady
### Problem
Nodes were randomly flipping to `NotReady` under normal-looking load.

### Investigation
SSM into an affected node and ran `free -h`:

```
Total        used        free      shared  buff/cache   available
Mem:          1.9Gi       1.7Gi        60Mi       3.0Mi       150Mi        50Mi
```
Almost no free memory remained.

### Root Cause
The `t3.small` instance (2 vCPU, 2 GB RAM) is simply too small for the number of pods that were being scheduled on it. More importantly, the kubelet was started **without** hard resource reservations (`--kube-reserved` and `--system-reserved`).

Without these reservations, pods were allowed to consume virtually all OS memory. This starved the kubelet itself (especially the PLEG), causing it to stop reporting node status to the control plane. The node then appeared as `NotReady` instead of cleanly evicting pods or leaving them in `Pending`.

### Resolution / Engineering Note
- Explicitly set `--kube-reserved` and `--system-reserved` on the kubelet.
- Keep realistic `max-pods` values (see also #7 – Cluster Pool IPAM migration).
- Avoid over-packing small instances even when Cluster Pool IPAM removes the ENI/IP hardware limit.

### Lesson Learned
Small instances + missing kubelet resource reservations is a dangerous combination. Without reservations the node fails catastrophically (NotReady) instead of failing safely (pods Pending/Evicted).

*The stress test described in issue #10 reproduced the same underlying node-capacity problem under a higher workload burst.*

## 12. CoreDNS Pods Stuck NotReady
### Problem
CoreDNS pods were in Running state but NotReady.

### Investigation
Checked node routing tables directly.
```
ip route
default via 10.0.10.1 dev enp39s0 proto dhcp src 10.0.10.33 metric 512
```
### Root Cause
Same class of issue as #2. After an instance type change the CNI/Cilium
configuration still expected `ens+` interfaces, while the new instance type
used `enp39s0`.

## 13. GitHub Actions OIDC: "Not authorized to assume role"
### Problem
GitHub Actions failed with: Error: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity
### Investigation
```
GitHub repository       ✅
GitHub branch           ✅
GitHub Environment      ✅
OIDC token              ✅
token aud               ✅
token sub               ✅
IAM Role ARN            ✅
IAM Trust Policy        ✅
IAM OIDC Provider       ✅
GitHub → OIDC → AWS STS ✅ 
```

### Root Cause
Renaming the GitHub repository silently changed the OIDC sub claim format generated by GitHub.

**Old format:** `repo:Rehox0/allegro-analytics-eks:environment:dev`

**New format:** `repo:Rehox0@68498256/Multi-Cloud-Kubernetes-Platform@1205820214:environment:dev`

### Resolution
Updated the IAM Trust Policy to match the new ID-based format.

## 14. TargetGroupBinding: Health Checks Failing
### Problem
AWS Target Group health checks (curl) were failing to reach the pods.
### Thought Process
Based on previous network debugging (e.g., issue #3), skipped checking pods and Cilium policies and went straight to AWS Security Groups.
### Investigation
Checked SG attached to the Target Group.
`eks_node_sg != aws_ekscluster_sg`
### Root Cause
The target group was pointing at an unused Terraform-managed SG instead of the actual EKS cluster SG attached to the nodes. Changing the Target Group SG to `aws_ekscluster_sg` resolved the health checks immediately.
