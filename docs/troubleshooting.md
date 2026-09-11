# Troubleshooting & Engineering Challenges

This document records the main technical problems encountered while building
and operating the Kubernetes platform.

The goal is not to document every minor configuration issue, but to capture
problems that required meaningful investigation, debugging, or architectural
changes. 
It includes raw errors, troubleshooting paths, and thought processes for future reference.

*(Note: There was also a huge amount of Terraform AWS & Azure configuration problems, but they are not documented here).*

## 1. Terraform apply + Cluster in Private Subnets
#### Problem

Terraform was unable to install/configure Kubernetes and Helm resources during
the initial Terraform apply.

The Kubernetes API and workloads were running in private networking, while
Terraform was executing from outside the VPC.

#### Resolution

Kubernetes/Helm resources were separated from the initial Terraform bootstrap
and later moved to ArgoCD/GitOps management.

#### Lesson Learned

Infrastructure provisioning and Kubernetes application/platform management have
different networking and lifecycle requirements.

## 2. Cilium Egress Masquerading Interface
#### Problem

Cilium networking was not behaving as expected after enabling native routing.

#### Resolution

The configured `egressMasqueradeInterfaces` did not match the actual network
interface used by the EC2 nodes.

The configuration assumed: ```ens+```

While the node interface was: ```enp39s0```

#### Lesson Learned

Never assume Linux network interface naming. Verify the actual interface with
`ip route`, `ip addr`, or similar tools before configuring CNI networking.

## 3. ArgoCD / ESO - AWS SG connectivity
#### Problem

External Secrets Operator could not obtain AWS credentials through IRSA.
ArgoCD reported an invalid provider configuration. 

#### Investigation
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

## 4. Pod IP Exhaustion on t3.small

Nodes started rejecting new pods once available IPs ran out. Bumping to `t3.medium` wasn't an option
(blocked by free-tier ASG limits), so the workaround was adding more `t3.small` nodes instead:
3 nodes × 3 ENIs × 4 IPs = 36 usable pod IPs.

## 5. Gateway API CRD Version Mismatch
#### Problem
Cilium had `enable-gateway-api=true` and could see the `GatewayClass`, but never took ownership of it.

#### Debugging Path:
```
enable-gateway-api=true in Cilium         ✅
Cilium dont took ownership GatewayClass   ❌
Cilium see GatewayClass                   ✅
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
#### Root Cause
Mismatch in Gateway API CRD version. Cilium 1.17.4 only supports Gateway API up to v1.6.1. Installing the exact matching CRD version resolved the issue.

## 6. Frontend → Backend Traffic Blocked
 
`HTTPRoute` was configured correctly; the missing piece was a `NetworkPolicy` allowing the traffic -
added it and the route started working.

## 7. Cluster Pool IPAM Migration
#### Problem/Context
Switching IPAM from AWS ENI-based to Cluster Pool meant pod capacity per node was no longer tied to
ENI/IP hardware limits (for t3.small: 3 ENI * 4 IP = 12 IPs -> max 11 pods).

#### Resolution & Risk
`kubelet max-pods` needed to be set explicitly (e.g., 11). While Cluster Pool allows bypassing ENI limits, artificially inflating `max-pods` on small instances without adjusting Kubelet resource reservations directly leads to OOM and node failures (see #10 & #11)
      
## 8. ArgoCD Repo-Server Cross-Node Networking
#### Problem
Pod-to-pod traffic between ArgoCD components on different nodes was silently failing.
#### Workaround Applied
Changed Cilium routing mode from native to tunnel (VXLAN).

#### Engineering Note (Root Cause)
Changing to Tunnel is a workaround, not a fix. Native routing failed because either AWS Route Tables lacked routes to Pod CIDRs on other nodes, or Security Groups between nodes did not allow native pod IP traffic. VXLAN works because it encapsulates pod traffic into UDP packets (port 4240) sent over the main node IPs, which the SG already allowed. For production AWS setups, native routing via Cilium ENI IPAM is preferred.

## 9. Karpenter Nodes Not Registering
#### Problem
Karpenter provisioned nodes successfully, but they never joined the EKS cluster.
#### Error Log (Node level)
```
cloud-init: Unhandled unknown content-type (application/node.eks.aws) userdata
```
#### Root Cause 
The provisioned AMI was not compatible with the userdata format Karpenter was sending. Switching to a compatible EKS-optimized AMI fixed registration.

## 10 & 11. Resource Starvation on t3.small (Stress Test & Random NotReady)
#### Problem
Deploying 30 pods at once on `t3.small` nodes hit Cilium's endpoint-creation rate limit
(`429 TooManyRequests`), and 2 of 3 nodes flipped to `NotReady` during the burst.

#### Investigation (SSM to NotReady Node)
```
sh-5.2$ free -h
              total        used        free      shared  buff/cache   available
Mem:          1.9Gi       1.7Gi        60Mi       3.0Mi       150Mi        50Mi
```
#### Root Cause & Engineering Note
The instance (t3.small - 2 vCPU, 2GB RAM) is simply too small for heavy Kubernetes workloads. More importantly, the nodes crashed because Kubelet lacked hard resource reservations (--kube-reserved and --system-reserved). Without these, pods consumed all OS memory, causing Kubelet (PLEG) to starve, stop reporting to the control plane, and crash the node instead of cleanly leaving pods in a Pending or Evicted state.

## 12. CoreDNS Pods Stuck NotReady
#### Problem
CoreDNS pods were in Running state but NotReady.
#### Investigation
Checked node routing tables directly.
```
ip route
default via 10.0.10.1 dev enp39s0 proto dhcp src 10.0.10.33 metric 512
```
#### Root Cause
Similar to issue #2. This was caused by an instance type change. The CNI/Cilium was still configured to look for ens+ interfaces, while the new instance type used enp39s0. Updated Cilium config to match.

## 13. GitHub Actions OIDC: "Not authorized to assume role"
#### Problem
GitHub Actions failed with: Error: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity
#### Debugging Path
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

#### Root Cause
Renaming the GitHub repository silently changed the OIDC sub claim format generated by GitHub.
Old format: repo:Rehox0/allegro-analytics-eks:environment:dev

- New format: repo:Rehox0@68498256/Multi-Cloud-Kubernetes-Platform@1205820214:environment:dev
- Updated the IAM Trust Policy to match the new ID-based format.

## 14. TargetGroupBinding: Health Checks Failing
#### Problem
AWS Target Group health checks (curl) were failing to reach the pods.
#### Thought Process
Based on previous network debugging (e.g., issue #3), skipped checking pods and Cilium policies and went straight to AWS Security Groups.
#### Investigation
Checked SG attached to the Target Group.
`eks_node_sg =/= aws_ekscluster_sg`
#### Root Cause
The target group was pointing at an unused Terraform-managed SG instead of the actual EKS cluster SG attached to the nodes. Changing the Target Group SG to `aws_ekscluster_sg` resolved the health checks immediately.