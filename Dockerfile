FROM alpine:latest 

ARG KUSTOMIZE_VERSION=v5.7.1 \
    KREW_VERSION=v0.4.5 \
    KOMPOSE_VERSION=v1.36.0

ARG TARGETPLATFORM \
    BUILDPLATFORM

ARG WORKDIR=/workspace

WORKDIR ${WORKDIR}

ENV KUBECONFIG=${WORKDIR}/.kube/config \
    XDG_CONFIG_HOME=${WORKDIR} \
    ENABLE_ALPHA_PLUGINS="true" \
    PATH="${WORKDIR}/.krew/bin:${WORKDIR}/bin:$PATH"

RUN apk --no-cache --update add \
    curl git gettext bash kubectl helm yq fzf docker-cli docker-compose

RUN <<EOF
addgroup -g 1000 krm
adduser -u 1000 -G krm -h ${WORKDIR} -s /bin/bash -D -S krm
mkdir -p "${WORKDIR}" "${WORKDIR}/.kube" "${WORKDIR}/.krew" "${WORKDIR}/kustomize" "${WORKDIR}/tmp"
chown -R krm:krm ${WORKDIR}

addgroup -g 983 docker
addgroup krm docker
EOF

RUN <<EOF
ARCH="${TARGETPLATFORM#*/}"
OS="${TARGETPLATFORM%%/*}"

echo "installing Kustomize"
curl -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz" | tar -xz -C /usr/local/bin kustomize
chmod +x /usr/local/bin/kustomize

echo "Installing Krew"
KREW="krew-${OS}_${ARCH}"
curl -L "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" -o tmp/${KREW}.tar.gz
tar -xzf tmp/${KREW}.tar.gz -C tmp
chmod +x tmp/${KREW}
mv tmp/${KREW} /usr/local/bin/kubectl-krew

echo "Install Kompose"
curl -L "https://github.com/kubernetes/kompose/releases/download/${KOMPOSE_VERSION}/kompose-linux-${ARCH}" -o /usr/local/bin/kubectl-kompose
chmod +x /usr/local/bin/kubectl-kompose
EOF

ENTRYPOINT ["kubectl"]
