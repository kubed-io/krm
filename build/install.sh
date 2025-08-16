#!/usr/bin/env bash

ARCH="${TARGETPLATFORM#*/}"
OS="${TARGETPLATFORM%%/*}"

echo "installing Kustomize"
curl -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz" | tar -xz -C /usr/local/bin kustomize
chmod +x /usr/local/bin/kustomize

echo "Installing Krew"
KREW="krew-${OS}_${ARCH}"
curl -L "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" -o tmp/${KREW}.tar.gz
tar -xzf tmp/${KREW}.tar.gz -C tmp
mv tmp/${KREW} /usr/local/bin/kubectl-krew

echo "Install Kompose"
curl -L "https://github.com/kubernetes/kompose/releases/download/${KOMPOSE_VERSION}/kompose-linux-${ARCH}" -o /usr/local/bin/kubectl-kompose

chmod +x /usr/local/bin/kubectl-*

PLUGIN_DIR="${WORKDIR}/kustomize/plugin/krm.kubed.io"

for dir in "$PLUGIN_DIR"/*/; do
    dirname=$(basename "$dir")
    file="$dir$dirname"
    if [ -f "$file" ]; then
        chmod +x "$file"
        echo "Made $file executable"
    fi
done

rm -rf "${WORKDIR}/tmp"
