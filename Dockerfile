FROM alpine:latest AS krm

ARG KUSTOMIZE_VERSION=v5.7.1 \
    KREW_VERSION=v0.4.5 \
    KOMPOSE_VERSION=v1.36.0 \
    YQ_VERSION=v4.47.1

ARG TARGETPLATFORM \
    BUILDPLATFORM

ARG WORKDIR=/workspace

WORKDIR ${WORKDIR}

ENV KUBECONFIG=${WORKDIR}/.kube/config \
    XDG_CONFIG_HOME=${WORKDIR} \
    ENABLE_ALPHA_PLUGINS="true" \
    PATH="${WORKDIR}/.krew/bin:${WORKDIR}/kubectl:$PATH" \
    HELM_CACHE_HOME=${WORKDIR}/helm/cache \
    HELM_CONFIG_HOME=${WORKDIR}/helm/config \
    HELM_DATA_HOME=${WORKDIR}/helm/data

COPY ./kubectl ./kubectl 
COPY ./kustomize ./kustomize
COPY ./build ./build

RUN apk --no-cache --update add \
    curl git gettext bash kubectl helm fzf docker-cli docker-compose

RUN <<EOF
addgroup -g 1000 krm
adduser -u 1000 -G krm -h ${WORKDIR} -s /bin/bash -D -S krm
mkdir -p "${WORKDIR}" "${WORKDIR}/.kube" "${WORKDIR}/.krew" "${WORKDIR}/tmp" \
    "${WORKDIR}/helm" "${WORKDIR}/helm/cache" "${WORKDIR}/helm/data" "${WORKDIR}/helm/config"
chown -R krm:krm ${WORKDIR}

addgroup -g 983 docker
addgroup krm docker
chmod +x ${WORKDIR}/build/*
chmod +x ${WORKDIR}/kubectl/*
EOF

RUN ${WORKDIR}/build/install.sh

ENTRYPOINT ["kubectl"]

##
# Dev container build
# docs: https://github.com/microsoft/vscode-dev-containers/blob/main/containers/python-3/README.md
# Makes the dev container environment
##
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu AS dev
ARG NODE_VERSION="none"

COPY --from=krm \
    /usr/local/bin/kustomize \
    /usr/local/bin/kubectl-krew \
    /usr/local/bin/kubectl-kompose \
    /usr/local/bin/

RUN <<EOF 
export DEBIAN_FRONTEND=noninteractive && apt-get update
apt-get -y install --no-install-recommends direnv yq
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/library-scripts 
mkdir -p "${HOME}/.kube" "${HOME}/.krew" "${HOME}/kustomize" "${HOME}/tmp"
EOF
