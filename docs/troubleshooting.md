# Troubleshooting & Engineering Challenges

This document records the main technical problems encountered while building
and operating the Kubernetes platform.

The goal is not to document every minor configuration issue, but to capture
problems that required meaningful investigation, debugging, or architectural
changes.

There was also huge amout of Terraform AWS & Azure configuration problems, but not documented here.

## 1. Terraform apply + Cluster in Private Subnets
```
### Problem

Terraform was unable to install/configure Kubernetes and Helm resources during
the initial Terraform apply.

The Kubernetes API and workloads were running in private networking, while
Terraform was executing from outside the VPC.

### Resolution

Kubernetes/Helm resources were separated from the initial Terraform bootstrap
and later moved to ArgoCD/GitOps management.

### Lesson Learned

Infrastructure provisioning and Kubernetes application/platform management have
different networking and lifecycle requirements.
```

## 2. Cilium Egress Masquerading Interface
```
### Problem

Cilium networking was not behaving as expected after enabling native routing.

### Resolution

The configured `egressMasqueradeInterfaces` did not match the actual network
interface used by the EC2 nodes.

The configuration assumed:
```
ens+
```

while the node interface was:
```
enp39s0
```


### Lesson Learned

Never assume Linux network interface naming. Verify the actual interface with
`ip route`, `ip addr`, or similar tools before configuring CNI networking.

```

## 3. ArgoCD / ESO - AWS SG connectivity
### Problem

External Secrets Operator could not obtain AWS credentials through IRSA.
ArgoCD reported an invalid provider configuration. 

### Investigation
InvalidProviderConfig:
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
 
Cilium had `enable-gateway-api=true` and could see the `GatewayClass`, but never took ownership of it -
RBAC, the operator, and the CRD were all present and healthy, and restarting Cilium (the documented fix)
didn't help. Validation errors on `status.supportedFeatures` (expecting `string`, getting `object`)
traced it back to the installed CRD version: Cilium 1.17.4 only supports Gateway API up to v1.6.1.
Installing the matching CRD version fixed it.

5.1(old) Problem z gateway
      enable-gateway-api=true w Cilium ✅
      Cilium nie przejął GatewayClass
      Cilium widzi GatewayClass ✅
      Cilium Operator 2/2 ✅
      Gateway API CRD ✅
      Cilium operator obserwuje GatewayClass:
            Doc zaleca restart cilium -> nie pomaga
      ClusterRole ✅
      ClusterRoleBinding ✅
      SA ✅
      RBAC ok ✅
      controllerName: io.cilium/gateway-controller ✅

      mismatch wersji Gateway API CRD -> Cilium 1.17.4. ❌
      status.supportedFeatures[0]: Invalid value: "object":
      supportedFeatures[0] in body must be of type string: "object"
      status.supportedFeatures[1]: Invalid value: "object"
      ...
      status.supportedFeatures[26]: Invalid value: "object"
      Duplicate value: {}

      Cilium supports Gateway API v1.6.1 


## 6. Frontend → Backend Traffic Blocked
 
`HTTPRoute` was configured correctly; the missing piece was a `NetworkPolicy` allowing the traffic -
added it and the route started working.

## 7. Cluster Pool IPAM Migration
 
Switching IPAM from AWS ENI-based to Cluster Pool meant pod capacity per node was no longer tied to
ENI/IP math, so `kubelet`'s max-pods needed to be set explicitly (11) instead of relying on the old default.
      
7.1(old) Problem z pula IP:
      refractor from ipam: eni -> cluster-pool
      kubelet = 11max Pod
      
## 8. ArgoCD Repo-Server Cross-Node Networking
 
Pod-to-pod traffic between nodes was silently failing. Switching Cilium's routing mode from native to
VXLAN tunneling resolved it.

8.1 Problem z ArgoCD - repo server:
      nie dziala pod -> pod miedzy nodami.
      ✅✅✅ zmiana z routing native na tunell ✅✅✅

## 9. Karpenter Nodes Not Registering
 
Karpenter provisioned nodes fine, but they never joined the cluster. `cloud-init` was rejecting the
userdata (`Unhandled unknown content-type (application/node.eks.aws)`) — the AMI didn't match what
Karpenter expected. Switching to a compatible AMI fixed registration.
 
9.1 Problem z Karpenter - Nody nie rejestruja sie w EKS:
      Nody sie scaluja ✅
      Problem z AMI Karpenter
      cloud-init: Unhandled unknown content-type (application/node.eks.aws) userdata
      ✅✅✅ zmiana na compatible AMI ✅✅✅

## 10. Stress Test: kubelet Unresponsive
 
Deploying 30 pods at once on `t3.small` nodes hit Cilium's endpoint-creation rate limit
(`429 TooManyRequests`), and 2 of 3 nodes flipped to `NotReady` during the burst.


10.1(old) Stress Test: kubelet no response
        A deployment containing 30 Pods was created simultaneously on a cluster
running on `t3.small` nodes -> cilium [429] putEndpointIdTooManyRequests
        2/3 Node Ready, next 1/3

## 11. Node Randomly Going NotReady
 
SSM'd into the affected instance and ran `free -h`: 60Mi free out of 1.9Gi. The instance was simply
too small for the number of pods scheduled on it.

11.1(old) Problem z losowym wylaczaniem sie Node:
      inspekcja node when NotReady:
      ssm to instacje ->  sh-5.2$ free -h
      total 1.9Gi, free 60Mi.
      Instancja jest za mała na tyle podów

## 12. CoreDNS Pods Stuck NotReady
 
Same root cause as the earlier Cilium interface issue (see #2), just triggered again by a later
instance type change: `ip route` showed `enp39s0`, but Cilium was still configured for the `ens+`
naming pattern from the old instance type.

12.1(old) Problem z CoreDNS
      coredns pody - running, NotReady
      szybkie sprawdzenie logow.
      problemem byla zmiana typu instancji.
      problem z dopasowaniem konfiguracji do instancji.
      sprawdzenie ip route na node:
            default via 10.0.10.1 dev enp39s0 proto dhcp src 10.0.10.33 metric 512
      ens+ =/= enp
      zmiana konfiguracji cilium

## 13. GitHub Actions OIDC: "Not authorized to assume role"
 
Repo, branch, environment, token claims, IAM role, trust policy, OIDC provider — checked all of it,
all correct. Turned out renaming the GitHub repo changed the OIDC `sub` claim format:
```
old: repo:Rehox0/allegro-analytics-eks:environment:dev
new: repo:Rehox0@68498256/Multi-Cloud-Kubernetes-Platform@1205820214:environment:dev
```

13.1(old) Problem z GHA "Error: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity"
      ✅ GitHub repository
      ✅ GitHub branch
      ✅ GitHub Environment
      ✅ OIDC token
      ✅ token aud
      ✅ token sub
      ✅ IAM Role ARN
      ✅ IAM Trust Policy
      ✅ IAM OIDC Provider
      ✅ GitHub → OIDC → AWS STS
      
      Po zmianie nazwy repozytorium GitHub OIDC sub zmienił format.
      Stary format:

      repo:Rehox0/allegro-analytics-eks:environment:dev

      Aktualny format:

      repo:Rehox0@68498256/Multi-Cloud-Kubernetes-Platform@1205820214:environment:dev

## 14. TargetGroupBinding: Health Checks Failing
 
Recognized this one from the earlier SG issues (#3) and went straight for Security Groups instead of
re-checking Cilium/pods first. Correct guess: the target group was pointing at an unused
Terraform-managed SG instead of the actual EKS cluster SG attached to the nodes. Pointed it at the
right SG and health checks passed.

14.1(old) tg_binding -> error: curl nie przechodzi
      thought process: probably sg missmatch
      ominalem sprawdzanie cilium i podow itd -> wczesniej byly podobne problemy i to jest najbardziej prawdopodobna przyczyna

      sprawdzenie sg dla tg->
      eks_node_sg =/= aws_ekscluster_sg
      zmiana tg_sg na aws_ekscluster_sg ✅