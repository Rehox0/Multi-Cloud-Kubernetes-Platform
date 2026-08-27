# The draft
# Troubleshooting & Engineering Challenges

This document records the main technical problems encountered while building
and operating the Kubernetes platform.

The goal is not to document every minor configuration issue, but to capture
problems that required meaningful investigation, debugging, or architectural
changes.

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
ens+
while the node interface was:
enp39s0

### Lesson Learned

Never assume Linux network interface naming. Verify the actual interface with
ip route, ip addr, or similar tools before configuring CNI networking.
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
      Wrong certificates?
      DNS           ✅
      K8s Service   ✅
      Endpoints     ✅
      TLS handshake ✅
      webhook:
            cert SAN  ✅
            CA        ✅
            Secret    ✅
            Deployment✅
            Endpoint  ✅
            response  ✅
      Service name      ✅
      Namespace	        ✅
      Endpoint response	✅
      client ➔ webhooka ✅
      TCP               ✅
      kube-apiserver ➔ webhook ❌

      kube-apiserver ➔ Service external-secrets-operator-webhook ➔ Pod external-secrets-webhook ✅ 
      diff ca.crt webhook-ca.crt ✅.

      Network, Service, Endpoints & TLS ✅

      API Server ➔ Service 172.20.243.138:443 ➔ Pod 10.0.11.164:10250

      ❌ problem for now: AWS STS connectivity IRSA

      ✅ ClusterIP
      ✅ kube-proxy/Cilium routing

      ✅ DNS & endpoint STS
      ❌ TCP 443 ➔ VPC Endpoint

      Endpoint SG inbound:
      ✅ sg-02e1fb4ec9295872c
      ❌ sg-085e462b302b47fca

      To check:
      [] NACL subnets endpoints
      [] route table subnets
      [] Cilium egress policy / BPF
      [] SG for ENI

      ✅ VPC Endpoint ENI SG:

      10.0.10.171 -> sg-03ee5f8c0790c08ba
      10.0.11.238 -> sg-03ee5f8c0790c08ba
      10.0.12.31  -> sg-03ee5f8c0790c08ba

      ✅ Endpoint SG ingress:

      sg-02e1fb4ec9295872c (nodes)
      sg-0a9108dda1e42ce13 (cilium)

      ❌ Pod ➔ (sg-085e462b302b47fca) ➔ VPC Endpoint ENI (sg-03ee5f8c0790c08ba)
      ❌ sg-085e462b302b47fca -> sg-03ee5f8c0790c08ba :443


      ✅✅✅✅✅ node SG ≠ pod ENI SG ✅✅✅✅✅

      VPC Endpoint SG
            |
            +-- sg-02e1fb4ec9295872c  (nodes)
            |
            +-- sg-0a9108dda1e42ce13  (Cilium ENI)
            |
            +-- sg-085e462b302b47fca  (EKS cluster/pod traffic)

      SG cilium_enis nie jest używany przez żaden ENI.

      Pod (10.0.10.41)
            |
            | veth
            |
      Cilium host routing
            |
            | SNAT/masquerade
            |
      Node ENI (10.0.10.167)
            |
            |
      VPC Endpoint ENI (10.0.10.171)


      Pod 10.0.10.41
            |
            |
      veth
            |
      Node 10.0.10.167
            |
            |
      AWS VPC
            |
            |
      Interface Endpoint 10.0.10.171

      Cilium nie blokuje ruchu. Problem jest niżej — routing / AWS networking / NAT do VPC endpointów STS.

      NetworkPolicy ✅
      Cilium policy ✅
      kube-proxy replacement ✅
      BPF routing ✅

      Connection timed out: Pod & Node (curl -v --connect-timeout 5 https://sts.eu-north-1.amazonaws.com)
      NACL inbound & outbound [*]
      route tables OK

      Flow Logs: ENI(10.0.12.31) ->

      @timestamp	srcAddr	dstAddr	srcPort	dstPort	protocol	action	logStatus
            2026-08-07T16:33:07.000Z	10.0.10.201	10.0.12.31	42838	443	6	REJECT	OK
            2026-08-07T16:30:47.000Z	10.0.10.121	10.0.12.31	47078	443	6	REJECT	OK

      actionREJECT
      bytes300
      dstAddr10.0.12.31
      dstPort443
      end1786120447
      interfaceIdeni-0c30616ac4e80515c
      logStatusOK
      packets5
      protocol6
      srcAddr10.0.10.201
      srcPort42838

      actionREJECT
      bytes420
      dstAddr10.0.12.31
      dstPort443
      end1786120307
      interfaceIdeni-0c30616ac4e80515c
      logStatusOK
      packets7
      protocol6
      srcAddr10.0.10.121
      srcPort47078

      Przyczyna blokady

      Pody wysyłają ruch bezpośrednio pod własnymi IP, przez co pakiet do interfejsu VPC Endpointa dociera z identyfikatorem Security Group przypisanym do Podów / ruchu klastra (sg-085e462b302b47fca).

      Security Group przypisany do VPC Endpointów STS (sg-03ee5f8c0790c08ba) nie posiada (Inbound Rule) zezwalającej na ruch z tej grupy!

5. Problem with IP poll size:
      tried to change to t3.medium. -> error with autoscaling group. T3.medium nie mozna postawic na free tier.
      3 nodes × 3 ENI × 4 IP = 36 IP (t3.small)
      Proba zwiekszenia ilosci nodow
6. Problem z gateway
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
      
7. Frontend -> Backend error:
      HTTPRoute ✅
      NetPol ❌
            
8. Problem z pula IP:
      refractor from ipam: eni -> cluster-pool
      kubelet = 11max Pod
      

9. Problem z ArgoCD - repo server:
      nie dziala pod -> pod miedzy nodami.
      ✅✅✅ zmiana z routing native na tunell ✅✅✅

10. Problem z Karpenter - Nody nie rejestruja sie w EKS:
      Nody sie scaluja ✅
      Problem z AMI Karpenter
      cloud-init: Unhandled unknown content-type (application/node.eks.aws) userdata
      ✅✅✅ zmiana na compatible AMI ✅✅✅
      

11. Stress Test: kubelet no response
        A deployment containing 30 Pods was created simultaneously on a cluster
running on `t3.small` nodes -> cilium [429] putEndpointIdTooManyRequests
        2/3 Node Ready, next 1/3
            

12. Problem z losowym wylaczaniem sie Node:
      inspekcja node when NotReady:
      ssm to instacje ->  sh-5.2$ free -h
      total 1.9Gi, free 60Mi.
      Instancja jest za mała na tyle podów

13. Problem z CoreDNS
      coredns pody - running, NotReady
      szybkie sprawdzenie logow.
      problemem byla zmiana typu instancji.
      problem z dopasowaniem konfiguracji do instancji.
      sprawdzenie ip route na node:
            default via 10.0.10.1 dev enp39s0 proto dhcp src 10.0.10.33 metric 512
      ens+ =/= enp
      zmiana konfiguracji cilium