# Architecture & Design Decisions

This document captures the main architectural decisions made while building the multi-cloud Kubernetes platform (AWS EKS + Azure AKS).

## Table of Contents

1. [Terraform & AKS Access](#terraform--aks-access---design-decision)
2. [Azure Ingress Architecture](#azure-ingress-architecture---design-decision)
3. [Secrets Management](#secrets-management---design-decision)
4. [Cilium Networking](#cilium-networking---design-decision)
5. [Argo CD Bootstrap](#argo-cd-bootstrap---design-decision)

---

# Terraform & AKS Access - Design Decision
One of the first architectural decisions was how to manage a private AKS cluster while keeping infrastructure provisioning reproducible and cluster administration practical.

Initially, Terraform managed both cloud infrastructure and Kubernetes components such as Cilium and Helm releases, with Terraform execution performed through GitHub Actions. This provided a remote and reproducible execution environment, but became relatively slow and introduced additional complexity when accessing the private cluster.

The project was therefore split into two responsibilities:

**Terraform** - provisions and manages cloud infrastructure.

**Jumpbox** - provides controlled access to the private AKS cluster and handles cluster-level operations and bootstrap.

The resulting architecture is:

```
Developer
    │
    │ controlled access
    ▼
Jumpbox
    │
    ├── kubectl
    ├── Helm
    ├── Cilium
    └── Argo CD
          │
          ▼
      Private AKS
```

As part of the decision, I deliberately tested two approaches for remote cluster administration.

On AWS, the jumpbox is accessed through AWS Systems Manager Session Manager. On Azure, the jumpbox is accessed through SSH.

This comparison was intentional: rather than choosing one approach purely from documentation, I wanted to evaluate both in actual day-to-day cluster administration.

In practice, SSH on Azure proved significantly faster and more responsive for interactive administration, while Session Manager introduced more operational overhead for this workflow. Both approaches keep the Kubernetes API private, but the experience showed that the access mechanism also needs to be evaluated from an operational perspective, not only from a security standpoint.

The final model therefore keeps the infrastructure reproducible through Terraform while providing a dedicated environment for cluster administration. Cluster access no longer depends on a particular developer workstation or requires exposing the Kubernetes API publicly.

**Cost consideration:** The jumpbox introduces an additional cloud resource, but the relatively small infrastructure cost is justified by simpler and faster cluster administration without exposing the private Kubernetes API.

---

# Azure Ingress Architecture - Design Decision

The Azure ingress architecture went through several iterations while solving a key integration problem: how to expose the Cilium Gateway to Azure Front Door without tightly coupling Terraform to AKS-managed infrastructure.

The target architecture is:

```
                Internet
                    ↓
         Azure Front Door Premium
                    ↓
              Private Link
                    ↓
       Azure Private Link Service
                    ↓
      Azure Internal Load Balancer
                    ↓
              Cilium Gateway
                    ↓
                   AKS
```
## Design constraints

The main challenge was the ownership boundary between Terraform and AKS.

The Cilium Gateway creates a Kubernetes LoadBalancer service, which in Azure results in AKS/Cilium-managed Load Balancer infrastructure. Terraform cannot simply create an arbitrary Azure Load Balancer and then have AKS transparently adopt and manage it as its own.

Several alternatives were evaluated.

## Rejected approaches

### Terraform-managed Load Balancer → AKS VMSS nodes

```
               Front Door
                    ↓
          Terraform-managed ILB
                    ↓
           AKS VMSS / NodePort
                    ↓
              Cilium Gateway
```

This required Terraform to manage AKS VMSS NICs and backend pool membership.

It introduced unnecessary coupling to AKS-managed resources and created additional problems around node lifecycle, autoscaling, permissions and Azure API behaviour.

A related limitation is that Azure Load Balancer backend pools using explicit IP addresses cannot be used as the backend of an Azure Private Link Service:

`PrivateLinkServiceIsNotSupportedForIPBasedLoadBalancer`

Therefore, this approach was discarded.

### Application Gateway

Another option was:

```
            Front Door
                ↓
        Application Gateway
                ↓
          Cilium Gateway
                ↓
               AKS
```

This avoids some of the Load Balancer ownership problems, but introduces a significant additional component and cost.

There is also an important Azure limitation: at the time of implementation, Private Link tunnelling to an Application Gateway with only private frontend IPs was not supported.

Using a public Application Gateway would therefore introduce additional exposure and cost while also making the Application Gateway WAF largely redundant with Front Door Premium WAF.

For this project, the additional complexity and cost were not justified.

### Final approach

The final design keeps ownership aligned with the platform that creates the resource.

Cilium creates the Gateway Load Balancer and its Private Link Service as part of the Kubernetes deployment:

```
            Terraform
                ↓
               AKS
                ↓
            Bootstrap
                ↓
          Cilium Gateway
                ↓
   Azure Internal Load Balancer
                ↓
    Azure Private Link Service
```

Terraform then waits for the PLS to become available before creating the dependent Front Door resources:

```
               AKS
                ↓
          Cilium Gateway
                ↓
        Internal LB + PLS
                ↓
          Terraform wait
                ↓
     Azure Front Door Premium
```

The dependency is therefore explicit rather than attempting to make Terraform manage infrastructure owned by AKS.

The Terraform workflow becomes:

1. Create Azure infrastructure
2. Create AKS
3. Create and configure jumpbox
4. Bootstrap Cilium and Gateway
5. Wait for the PLS to become ready
6. Create Azure Front Door

The bootstrap success becomes the integration point between AKS-managed infrastructure and Terraform-managed infrastructure.

## Trade-offs

This approach has several advantages:

- no manual modification of AKS VMSS resources
- no hardcoded AKS node IP addresses
- no additional Application Gateway
- Cilium/AKS owns its own Load Balancer
- Terraform retains ownership of Front Door
- the architecture is created in a single Terraform deployment
- significantly lower cost than introducing Application Gateway
- fewer networking components and less operational overhead

The main trade-off is that Front Door creation depends on successful cluster bootstrap.

If Cilium or the Gateway deployment fails, Terraform will stop while waiting for the Private Link Service rather than continuing to create the remaining ingress infrastructure.

This is intentional: the dependency represents a real infrastructure requirement rather than hiding it through manual deployment steps.

## Cost consideration

The selected architecture avoids the additional cost of Application Gateway WAF v2.

The main Azure ingress-related costs are therefore approximately:

| Component | Approximate cost |
|---|---:|
| Azure Front Door Premium | ~$330/month |
| Standard Azure Load Balancer | ~$18/month + data processing |
| Azure Private Endpoint | ~$7/month |
| Application Gateway WAF v2 | **Not required** |

Prices are approximate and depend on region, traffic and Azure pricing changes.

## Design conclusion

Azure does not provide an equivalent of the simple AWS integration initially considered for this architecture.

The final solution therefore follows Azure's resource ownership model instead of attempting to force Terraform to manage AKS-created networking resources.

---

# Secrets Management - Design Decision

A separate architectural decision was how Kubernetes workloads should access secrets without storing sensitive values directly in Git or tightly coupling the cluster to a single cloud provider.

Several approaches were considered:

- direct integration with a cloud secret store
- custom secret retrieval mechanism
- HashiCorp Vault
- External Secrets Operator (ESO)

The multi-cloud architecture introduced an additional question: should both environments use one centralized secret provider, or should each cloud use its native secret management service?

After a relatively quick evaluation, the decision was to use External Secrets Operator as the Kubernetes integration layer, while keeping the actual secret stores cloud-specific:

- AWS → AWS Secrets Manager
- Azure → Azure Key Vault
- Kubernetes → ESO-managed Kubernetes Secrets

This avoided introducing a separate centralized Vault infrastructure while preserving a consistent Kubernetes-facing interface. It also keeps cloud-specific responsibilities within their respective environments — if one cloud becomes unavailable, the other does not depend on the same external secret-management platform.

**Cost consideration:** Using the native secret store of each cloud avoids introducing the operational and infrastructure cost of a separate centralized Vault deployment, while still providing a consistent Kubernetes integration through ESO.

---

# Cilium Networking - Design Decision

When configuring Cilium networking on AWS, I initially chose native routing after researching the available networking models. It appeared to be the most natural approach for an AWS environment because pod traffic could be routed through the underlying VPC network without an overlay.

During implementation, however, a practical infrastructure constraint became apparent: the selected t3.small instances had a limited number of available IP addresses. With the planned pod density, native routing would require more IP capacity than the nodes could provide.

This made the original design impractical for the intended cluster configuration.

I therefore rolled back part of the networking configuration and switched Cilium to tunneling.

The main lesson was that choosing a networking model based only on its architectural characteristics was not enough. The decision also had to account for the concrete limitations of the underlying AWS instance types.

The final approach favored a slightly less direct networking model in exchange for predictable pod networking and compatibility with the available node capacity

---

# Argo CD Bootstrap - Design Decision

During the initial Argo CD setup, a dependency problem appeared: some platform components, including External Secrets Operator (ESO), required infrastructure that was not yet available, while Argo CD was attempting to synchronize Applications concurrently.

The initial approach was to look for a Terraform-like dependency mechanism between Argo CD Applications. Argo CD, however, does not provide a general depends_on mechanism for Applications.

Several alternatives were considered:

- custom controllers
- webhooks
- sync checks and health conditions
- ApplicationSets and synchronization ordering

While these approaches could provide more control over synchronization, they would also introduce additional logic and operational complexity for a relatively small bootstrap problem.

The final decision was to move the initial bootstrap dependency outside ArgoCD.

```
Cluster Bootstrap
       │
       ├── Cilium
       ├── Required infrastructure / CRDs
       │
       ▼
    Argo CD
       │
       ▼
 Platform Applications
       │
       ├── ESO
       ├── Monitoring
       ├── Gateways
       └── Workloads
```

Components required to make the cluster operational are installed by the initialization layer before Argo CD starts managing the remaining platform.

This establishes a clear separation of responsibilities: bootstrap prepares the cluster, while Argo CD continuously reconciles the desired state afterwards.

The decision avoided introducing custom synchronization mechanisms into Argo CD and kept the GitOps layer focused on its primary role rather than making it responsible for bootstrapping itself.

