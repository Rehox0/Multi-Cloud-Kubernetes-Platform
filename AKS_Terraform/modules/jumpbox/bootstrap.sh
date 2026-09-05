#!/bin/bash
set -euo pipefail

KUBECTL_VERSION="${kubectl_version}"
KUBECTL_SHA256="${kubectl_sha256}"
HELM_VERSION="${helm_version}"
HELM_SHA256="${helm_sha256}"
KUBELOGIN_VERSION="${kubelogin_version}"
KUBELOGIN_SHA256="${kubelogin_sha256}"

BOOTSTRAP_TMP_DIR="/tmp/jumpbox-bootstrap"
mkdir -p "$${BOOTSTRAP_TMP_DIR}"
echo "[bootstrap] using disk workspace: $${BOOTSTRAP_TMP_DIR}"

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y \
  ca-certificates \
  curl \
  git \
  gnupg \
  lsb-release \
  unzip

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# kubectl
curl -fsSLo "$${BOOTSTRAP_TMP_DIR}/kubectl" "https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
echo "$${KUBECTL_SHA256}  $${BOOTSTRAP_TMP_DIR}/kubectl" | sha256sum -c -
install -o root -g root -m 0755 "$${BOOTSTRAP_TMP_DIR}/kubectl" /usr/local/bin/kubectl

# kubelogin
echo "[bootstrap] Installing kubelogin"

curl -fsSLo "$${BOOTSTRAP_TMP_DIR}/kubelogin.zip" \
  "https://github.com/Azure/kubelogin/releases/download/$${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip"

echo "$${KUBELOGIN_SHA256}  $${BOOTSTRAP_TMP_DIR}/kubelogin.zip" | sha256sum -c -
unzip -q "$${BOOTSTRAP_TMP_DIR}/kubelogin.zip" -d "$${BOOTSTRAP_TMP_DIR}/kubelogin"
KUBELOGIN_BIN=$(find "$${BOOTSTRAP_TMP_DIR}/kubelogin" -type f -name kubelogin -print -quit)
test -n "$${KUBELOGIN_BIN}"
install -o root -g root -m 0755 "$${KUBELOGIN_BIN}" /usr/local/bin/kubelogin

#helm installation
curl -fsSLo "$${BOOTSTRAP_TMP_DIR}/helm.tar.gz" "https://get.helm.sh/helm-$${HELM_VERSION}-linux-amd64.tar.gz"
echo "$${HELM_SHA256}  $${BOOTSTRAP_TMP_DIR}/helm.tar.gz" | sha256sum -c -
tar -xzf "$${BOOTSTRAP_TMP_DIR}/helm.tar.gz" -C "$${BOOTSTRAP_TMP_DIR}"
install -o root -g root -m 0755 "$${BOOTSTRAP_TMP_DIR}/linux-amd64/helm" /usr/local/bin/helm


# AKS kubeconfig
echo "[bootstrap] Preparing kubeconfig directory"

KUBE_USER="azureadmin"
KUBE_HOME="/home/$${KUBE_USER}"
KUBE_DIR="$${KUBE_HOME}/.kube"
KUBE_CONFIG="$${KUBE_DIR}/config"

mkdir -p "$${KUBE_DIR}"
chown "$${KUBE_USER}:$${KUBE_USER}" "$${KUBE_DIR}"
chmod 700 "$${KUBE_DIR}"

echo "[bootstrap] Authenticating with managed identity"
az login --identity

echo "[bootstrap] Getting AKS credentials"
az aks get-credentials \
  --resource-group "Multi-Cloud-Project-rg" \
  --name "Multi-Cloud-Project-aks-cluster" \
  --file "$${KUBE_CONFIG}"   \
  --overwrite-existing

chown "$${KUBE_USER}:$${KUBE_USER}" "$${KUBE_CONFIG}"
chmod 600 "$${KUBE_CONFIG}"

export KUBECONFIG="$${KUBE_CONFIG}"

#Cilium installation + Gateway API CRDs
echo "[bootstrap] Installing Gateway API CRDs"
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.6.1/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.6.1/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.6.1/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.6.1/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.6.1/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.6.1/config/crd/standard/gateway.networking.k8s.io_backendtlspolicies.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.6.1/config/crd/standard/gateway.networking.k8s.io_tlsroutes.yaml

CLUSTER_INFO=$(az aks show \
  --resource-group Multi-Cloud-Project-rg \
  --name Multi-Cloud-Project-aks-cluster \
  --query "privateFqdn" \
  --output tsv)

CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$${CILIUM_CLI_VERSION}/cilium-linux-$${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-$${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-$${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-$${CLI_ARCH}.tar.gz{,.sha256sum}

helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade --install cilium cilium/cilium \
  --version 1.20.1 \
  --namespace kube-system \
  --set aksbyocni.enabled=true \
  --set ipam.mode=cluster-pool \
  --set ipam.operator.clusterPoolIPv4PodCIDRList="10.244.0.0/16" \
  --set ipam.operator.clusterPoolIPv4MaskSize=24 \
  --set routingMode=tunnel \
  --set tunnelProtocol=vxlan \
  --set kubeProxyReplacement=true \
  --set l7Proxy=true \
  --set gatewayAPI.enabled=true \
  --set k8sServiceHost="$${CLUSTER_INFO}" \
  --set k8sServicePort=443 \
  --wait \
  --timeout 3m

#PrioClass
kubectl apply -f - <<'EOF'
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: prio-critical
value: 1000000
globalDefault: false
description: "Critical infrastructure workloads"
EOF

# ArgoCD installation
helm repo add argoproj https://argoproj.github.io/argo-helm
helm upgrade --install argocd argoproj/argo-cd \
  --namespace argocd \
  --create-namespace \
  --set configs.params.server\.insecure=true \
  --set global.priorityClassName=prio-critical \
  --wait \
  --timeout 3m

# ESO installation
helm repo add external-secrets https://charts.external-secrets.io
helm upgrade --install eso-operator external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace \
  --version 2.8.0 \
  --set installCRDs=true \
  --set webhook.hostNetwork=true \
  --set webhook.hostUsers=true \
  --set webhook.dnsPolicy=ClusterFirstWithHostNet \
  --set webhook.port=10251 \
  --set webhook.priorityClassName=prio-critical \
  --wait \
  --timeout 3m

# Bash completion
echo "[bootstrap] Configuring bash completion"

apt-get install -y bash-completion

cat <<'EOF_BASH' >> /etc/bash.bashrc

# bash-completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# kubectl completion
if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion bash)
    alias k=kubectl
    complete -o default -F __start_kubectl k
fi

# helm completion
if command -v helm >/dev/null 2>&1; then
    source <(helm completion bash)
fi

# Azure CLI completion
if command -v az >/dev/null 2>&1; then
    source <(az completion --shell bash)
fi

EOF_BASH

chown azureadmin:azureadmin /home/azureadmin/.bashrc

# Cleanup

# rm -rf "$${BOOTSTRAP_TMP_DIR}"

echo "[bootstrap] Azure jumpbox setup completed"

