FROM alpine:latest AS krm

ARG KUSTOMIZE_VERSION=v5.7.1 \
    KREW_VERSION=v0.4.5 \
    KOMPOSE_VERSION=v1.37.0 \
    YQ_VERSION=v4.47.1

ARG TARGETPLATFORM \
    BUILDPLATFORM

ARG WORKDIR=/kubed \
    INSTALLDIR=/kubed/bin

WORKDIR ${WORKDIR}

ENV KUBECONFIG=${WORKDIR}/.kube/config \
    XDG_CONFIG_HOME=${WORKDIR} \
    ENABLE_ALPHA_PLUGINS="true" \
    PATH="${WORKDIR}/.krew/bin:${WORKDIR}/bin:$PATH" \
    HELM_CACHE_HOME=${WORKDIR}/.helm/cache \
    HELM_CONFIG_HOME=${WORKDIR}/.helm/config \
    HELM_DATA_HOME=${WORKDIR}/.helm/data

RUN apk --no-cache --update add \
    curl git gettext bash fzf docker-cli docker-compose

COPY ./kubectl ./bin 
COPY ./kustomize ./kustomize
COPY ./build ./build

RUN <<EOF
addgroup -g 1000 krm
adduser -u 1000 -G krm -h ${WORKDIR} -s /bin/bash -D -S krm
mkdir -p "${WORKDIR}" \
         "${WORKDIR}/tmp" \
         "${WORKDIR}/.kube" \
         "${WORKDIR}/.krew" \
         "${WORKDIR}/.helm" \
         "${WORKDIR}/.helm/cache" \
         "${WORKDIR}/.helm/data" \
         "${WORKDIR}/.helm/config"

chown -R krm:krm ${WORKDIR}

addgroup -g 983 docker
addgroup krm docker
chmod +x ${WORKDIR}/build/*
chmod +x ${WORKDIR}/bin/*
EOF

RUN ${WORKDIR}/build/install.sh

ENTRYPOINT ["kubectl"]

##
# Dev container build
# docs: https://github.com/microsoft/vscode-dev-containers/blob/main/containers/python-3/README.md
# Makes the dev container environment
##
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu AS dev

ARG NODE_VERSION="none" \
    TARGETPLATFORM="linux/amd64" \
    BUILDPLATFORM="linux/amd64"

USER root

COPY ./build /opt/tmp-build

RUN <<EOF 
mkdir /kubed 
chown -R vscode:vscode /kubed
chmod +x /opt/tmp-build/*
export WORKDIR=/opt/tmp-build 
/opt/tmp-build/install.sh
/opt/tmp-build/dev-install.sh direnv fzf 1password-cli
EOF

USER vscode

## 
# Now codeserver version as well
##
FROM codercom/code-server:latest AS codeserver 

ARG TARGETPLATFORM="linux/amd64" \
    BUILDPLATFORM="linux/amd64"

COPY ./build ./build

ENV KUBECONFIG=${WORKDIR}/.kube/config \
    XDG_CONFIG_HOME=${WORKDIR} \
    ENABLE_ALPHA_PLUGINS="true" \
    PATH="${WORKDIR}/.krew/bin:${WORKDIR}/bin:$PATH" \
    HELM_CACHE_HOME=${WORKDIR}/.helm/cache \
    HELM_CONFIG_HOME=${WORKDIR}/.helm/config \
    HELM_DATA_HOME=${WORKDIR}/.helm/data

RUN <<EOF 

# make some dirs 
mkdir -p /kubed /home/coder/.local/share/code-server
chown -R coder:coder /kubed /home/coder/.local/share/code-server

# add coder to docker group
groupadd -g 983 docker
usermod -aG docker coder

# install tools
chmod +x ./build/*
./build/dev-install.sh direnv fzf 1password-cli docker-ce-cli
./build/install.sh
EOF
