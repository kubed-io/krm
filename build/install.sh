#!/usr/bin/env bash

ARCH="${TARGETPLATFORM#*/}"
OS="${TARGETPLATFORM%%/*}"

INSTALLDIR="${INSTALLDIR:-/usr/local/bin}"
WORKDIR="${WORKDIR:-$PWD}"
TMPDIR="${WORKDIR}/tmp"

mkdir -p "$TMPDIR" "$INSTALLDIR"

echo "Installing kubectl"
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
KUBECTL_LATEST="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
KUBECTL_VERSION="${KUBECTL_VERSION:-$KUBECTL_LATEST}"
curl -L "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" -o ${INSTALLDIR}/kubectl
chmod +x ${INSTALLDIR}/kubectl

echo "installing Kustomize"
# https://github.com/kubernetes-sigs/kustomize/releases
KUSTOMIZE_VERSION="${KUSTOMIZE_VERSION:-v5.7.1}"
curl -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz" | tar -xz -C ${INSTALLDIR} kustomize
chmod +x ${INSTALLDIR}/kustomize

echo "Installing Krew"
# https://github.com/kubernetes-sigs/krew/releases
KREW="krew-${OS}_${ARCH}"
curl -L "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" -o "$TMPDIR/${KREW}.tar.gz"
tar -xzf "$TMPDIR/${KREW}.tar.gz" -C "$TMPDIR"
mv "${TMPDIR}/${KREW}" "${INSTALLDIR}/kubectl-krew"

echo "Installing Helm"
# https://github.com/helm/helm/releases
HELM_VERSION="${HELM_VERSION:-v3.19.0}"
curl -L "https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz" -o "$TMPDIR/helm.tar.gz"
tar -xzf "$TMPDIR/helm.tar.gz" -C "$TMPDIR"
mv "$TMPDIR/${OS}-${ARCH}/helm" "${INSTALLDIR}/helm"
chmod +x "${INSTALLDIR}/helm"

echo "Install Kompose"
# https://github.com/kubernetes/kompose/releases
KOMPOSE_VERSION="${KOMPOSE_VERSION:-v1.37.0}"
curl -L "https://github.com/kubernetes/kompose/releases/download/${KOMPOSE_VERSION}/kompose-linux-${ARCH}" -o ${INSTALLDIR}/kubectl-kompose

echo "Install YQ"
# https://github.com/mikefarah/yq/releases
YQ_VERSION="${YQ_VERSION:-v4.47.2}"
curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}" -o ${INSTALLDIR}/yq
chmod +x ${INSTALLDIR}/yq

chmod +x ${INSTALLDIR}/kubectl-*

PLUGIN_DIR="${WORKDIR}/kustomize/plugin/krm.kubed.io"

if [ -d "$PLUGIN_DIR" ]; then
  for dir in "$PLUGIN_DIR"/*/; do
      dirname=$(basename "$dir")
      file="${dir}${dirname}"
      if [ -f "$file" ]; then
          chmod +x "$file"
          echo "Made $file executable"
      fi
  done
fi

rm -rf "$TMPDIR"
