#!/bin/bash
set -euo pipefail

KUBECTL_VERSION="${kubectl_version}"
KUBECTL_SHA256="${kubectl_sha256}"
HELM_VERSION="${helm_version}"
HELM_SHA256="${helm_sha256}"
KUBELOGIN_VERSION="${kubelogin_version}"
KUBELOGIN_SHA256="${kubelogin_sha256}"

AKS_RESOURCE_GROUP="${aks_resource_group}"
AKS_CLUSTER_NAME="${aks_cluster_name}"

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
install -o root -g root -m 0755 "$${BOOTSTRAP_TMP_DIR}/kubelogin"/*/kubelogin /usr/local/bin/kubelogin

#helm installation
curl -fsSLo "$${BOOTSTRAP_TMP_DIR}/helm.tar.gz" "https://get.helm.sh/helm-$${HELM_VERSION}-linux-amd64.tar.gz"
echo "$${HELM_SHA256}  $${BOOTSTRAP_TMP_DIR}/helm.tar.gz" | sha256sum -c -
tar -xzf "$${BOOTSTRAP_TMP_DIR}/helm.tar.gz" -C "$${BOOTSTRAP_TMP_DIR}"
install -o root -g root -m 0755 "$${BOOTSTRAP_TMP_DIR}/linux-amd64/helm" /usr/local/bin/helm


# AKS kubeconfig
echo "[bootstrap] Preparing kubeconfig directory"

mkdir -p /root/.kube
chmod 700 /root/.kube


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

source /etc/bash.bashrc

# Cleanup

rm -rf "$${BOOTSTRAP_TMP_DIR}"

echo "[bootstrap] Azure jumpbox setup completed"
echo "[bootstrap] AKS: $${AKS_CLUSTER_NAME}"
echo "[bootstrap] Resource Group: $${AKS_RESOURCE_GROUP}"
