## Terraform & AKS Access - Design Decision
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


## Azure Ingress Architecture - Design Decision

The Azure ingress architecture evolved through several iterations while solving a key integration problem: how to provide Azure Front Door with a stable backend endpoint for the Cilium Gateway without coupling Terraform to AKS-managed infrastructure.

One of the factors behind the initial approach was the difference between the AWS and Azure networking models. In AWS, a similar integration can be relatively straightforward: a Load Balancer can use a Target Group containing the required targets, providing a clear and stable integration point.

Azure required a different approach. The Cilium Gateway did not initially provide the type of endpoint required for the planned Front Door integration, and creating an equivalent Terraform-managed Load Balancer meant integrating it with resources already managed by AKS.

The initial concept was:

```
Cilium Gateway
      ↓
No clear Azure backend endpoint
      ↓
Azure Front Door
```

Because of this, the first implementation introduced a Terraform-managed internal Azure Load Balancer:

```
Front Door
    ↓
Azure Load Balancer
    ↓
AKS VMSS / NodePort
    ↓
Cilium Gateway
```

This worked, but required Terraform to modify the network configuration of the AKS-managed VMSS and attach its NICs to the Load Balancer backend pool.

This introduced an unnecessary dependency on AKS-managed resources and created additional complexity around VMSS updates, Azure API behavior and permissions.

After further research, the architecture was redesigned around Azure Application Gateway and a Cilium LoadBalancer Service with a static private IP:

```
Front Door
    ↓
Application Gateway
    ↓
Internal Azure Load Balancer
    ↓
Cilium Gateway
    ↓
Applications / Services
```

The final responsibilities are clearly separated:

Argo CD / Kubernetes manages the Cilium Gateway and its LoadBalancer Service.
Azure provides the internal Load Balancer and its reserved private IP.
Terraform manages Application Gateway and uses the fixed Cilium Gateway IP as its backend.
AKS-managed VMSS remains completely untouched by Terraform.

The resulting architecture provides a stable integration point between the Azure infrastructure and Kubernetes ingress layers, while avoiding direct modification of AKS-managed resources.

The main design principle was to integrate with the interfaces provided by AKS and Kubernetes rather than taking ownership of resources managed internally by AKS.

**Cost consideration:** This architecture introduces additional Azure networking and Application Gateway costs compared with a simpler direct Load Balancer approach, but the additional cost is accepted in exchange for a stable ingress integration and clear separation between Azure infrastructure and AKS-managed resources.



## Secrets Management - Design Decision

A separate architectural decision was how Kubernetes workloads should access secrets without storing sensitive values directly in Git or tightly coupling the cluster to a single cloud provider.

Several approaches were considered:

```
Kubernetes
    │
    ├── direct integration with a cloud secret store
    ├── custom secret retrieval mechanism
    ├── HashiCorp Vault
    └── External Secrets Operator
            │
            ├── AWS Secrets Manager
            └── Azure Key Vault
```

The multi-cloud architecture introduced an additional question: should both environments use one centralized secret provider, or should each cloud use its native secret management service?

The final decision was to use External Secrets Operator (ESO) as the Kubernetes integration layer, while keeping the actual secret stores cloud-specific:

AWS → AWS Secrets Manager
Azure → Azure Key Vault
Kubernetes → ESO-managed Kubernetes Secrets

This avoided introducing a separate centralized Vault infrastructure while preserving a consistent Kubernetes-facing interface.

The architecture also keeps cloud-specific responsibilities within their respective environments. If one cloud becomes unavailable, the other does not depend on the same external secret-management platform for its workloads.

The result is a separation between secret storage and secret consumption: cloud providers remain responsible for securely storing secrets, while ESO handles synchronizing them into Kubernetes.

**Cost consideration:** Using the native secret store of each cloud avoids introducing the operational and infrastructure cost of a separate centralized Vault deployment, while still providing a consistent Kubernetes integration through ESO.



## Cilium Networking - Design Decision

When configuring Cilium networking on AWS, I initially chose native routing after researching the available networking models. It appeared to be the most natural approach for an AWS environment because pod traffic could be routed through the underlying VPC network without an overlay.

During implementation, however, a practical infrastructure constraint became apparent: the selected t3.small instances had a limited number of available IP addresses. With the planned pod density, native routing would require more IP capacity than the nodes could provide.

This made the original design impractical for the intended cluster configuration.

I therefore rolled back part of the networking configuration and switched Cilium to tunneling.

The main lesson was that choosing a networking model based only on its architectural characteristics was not enough. The decision also had to account for the concrete limitations of the underlying AWS instance types.

The final approach favored a slightly less direct networking model in exchange for predictable pod networking and compatibility with the available node capacity

## Argo CD Bootstrap - Design Decision

During the initial Argo CD setup, a dependency problem appeared: some platform components, including External Secrets Operator (ESO), required infrastructure that was not yet available, while Argo CD was attempting to synchronize Applications concurrently.

The initial approach was to look for a Terraform-like dependency mechanism between Argo CD Applications. Argo CD, however, does not provide a general depends_on mechanism for Applications.

Several alternatives were considered:

custom controllers,
webhooks,
sync checks and health conditions,
ApplicationSets and synchronization ordering.

While these approaches could provide more control over synchronization, they would also introduce additional logic and operational complexity for a relatively small bootstrap problem.

The final decision was to move the initial bootstrap dependency outside Argo CD.

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

