# Deployment Guide - Multi-Cloud Kubernetes Platform
Operational runbook for bootstrapping, deploying, and accessing the platform on AWS and Azure.

---

## ⚠️ Remote State (S3 Backend)
This project uses remote state stored in S3 with a lock in DynamoDB.

**Infrastructure parameters:**
- **Region:** `eu-central-1`
- **Bucket Name:** `multicloud-kubernetes-platform-tfstate-2026`
- **DynamoDB Table:** `terraform-state-lock`
- **Secrets Manager:** `aws-infra-project-dev` (development), `aws-infra-project-prod` (production)


**The bucket name must match in two places:**
1. `.bootstrap/variables.tf` → variable `state_bucket_name`
2. `./backend.tf` → the `bucket` parameter in the `backend "s3"` block

---
 
## ☁️ AWS Deployment

### 1. Bootstrap remote state
```bash
cd .bootstrap/
terraform apply
```

### 2. Deploy the dev environment
```bash
cd envs/dev/
terraform apply
```

### 3. Configure the management host
SSM into the `mgmt-asg` EC2 instance, then run the following.
 
**Remove the default AWS VPC CNI and restart core components** — required once Cilium is up; critical for a
clean config refresh:
```bash
kubectl delete ds aws-node -n kube-system
kubectl delete ds kube-proxy -n kube-system
kubectl rollout restart deployment coredns -n kube-system
kubectl rollout restart deployment -n external-secrets
```


**Deploy the GitOps root app:**
```bash
git clone -b testing https://github.com/Rehox0/Multi-Cloud-Kubernetes-Platform.git
kubectl apply -f ~/Multi-Cloud-Kubernetes-Platform/k8s/gitops/root/aws-root-app.yaml
kubectl rollout restart deployment -n argocd
kubectl rollout restart statefulset -n argocd
```

### 4. Access the ArgoCD UI
On the mgmt host:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Locally, tunnel to the mgmt host via SSM:
```bash
aws ssm start-session \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["8080"],"localPortNumber":["8080"]}' \
  --target <mgmt-instance-id>
```
Get the initial admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode; echo
```
### 5. Access the Grafana UI
```bash
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
```
```bash
aws ssm start-session \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["3000"],"localPortNumber":["3000"]}' \
  --target <mgmt-instance-id>
```
Get the admin password:
```bash
kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo
```
### 6. Access the Prometheus UI
```bash
kubectl port-forward -n monitoring pod/prometheus-kube-prometheus-stack-prometheus-0 9090:9090
```
```bash
aws ssm start-session \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["9090"],"localPortNumber":["9090"]}' \
  --target <mgmt-instance-id>
```
---
 
## ☁️ Azure Deployment
 
### 1. Deploy the GitOps root app
```bash
git clone -b testing https://github.com/Rehox0/Multi-Cloud-Kubernetes-Platform.git
kubectl apply -f ~/Multi-Cloud-Kubernetes-Platform/k8s/gitops/root/azure-root-app.yaml
```


git clone -b testing https://github.com/Rehox0/Multi-Cloud-Kubernetes-Platform.git
kubectl apply -f ~/Multi-Cloud-Kubernetes-Platform/k8s/gitops/root/azure-root-app.yaml

### 2. Access the ArgoCD UI
```bash
ssh -L 8080:127.0.0.1:8080 azureadmin@<azure-vm-ip> "kubectl port-forward -n argocd svc/argocd-server 8080:443 --address 127.0.0.1"
```
Get the initial admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode; echo
```
 
### 3. Approve the Front Door Private Link connection
Get the pending connection name:
```bash
az network private-link-service show \
  --name multicloudproject-frontdoor-pls \
  --resource-group Multi-Cloud-Project-rg \
  --query "privateEndpointConnections[].name" \
  -o tsv
```
Approve it:
```bash
az network private-link-service connection update \
  --name "<connection-name-from-previous-step>" \
  --service-name multicloudproject-frontdoor-pls \
  --resource-group Multi-Cloud-Project-rg \
  --connection-status Approved \
  --description "Approved Azure Front Door Premium Private Link connection"
```
