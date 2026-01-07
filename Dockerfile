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
FROM kubed/devcontainers:latest AS dev

ARG NODE_VERSION="none" \
    TARGETPLATFORM="linux/amd64" \
    BUILDPLATFORM="linux/amd64" \
    INSTALLDIR="/kubed/bin"

USER root

COPY ./build /kubed/build

RUN <<EOF 
chown -R vscode:vscode /kubed
export WORKDIR=/kubed/build
/kubed/build/install.sh
EOF

USER vscode

## 
# Now codeserver version as well
##
FROM kubed/devcontainers:codeserver AS codeserver 

ARG TARGETPLATFORM="linux/amd64" \
    BUILDPLATFORM="linux/amd64" \
    INSTALLDIR="/kubed/bin"

USER root

# COPY ./build ./build
COPY --from=krm --chown=coder:coder /kubed/bin /kubed/bin

RUN <<EOF 
# update the bashrc
cat <<EOT >> /home/coder/.bashrc

export PATH="/kubed/.krew/bin:/kubed/bin:\$PATH"
export KUBECTL_APPLYSET="true"

EOT
cat <<EOT >> /home/coder/.profile

export PATH="/kubed/.krew/bin:/kubed/bin:\$PATH"
export KUBECTL_APPLYSET="true"

EOT
EOF

USER coder 

ENV KUBECONFIG=/kubed/.kube/config \
    XDG_CONFIG_HOME=/kubed \
    ENABLE_ALPHA_PLUGINS="true" \
    PATH="/kubed/.krew/bin:/kubed/bin:$PATH" \
    HELM_CACHE_HOME=/kubed/.helm/cache \
    HELM_CONFIG_HOME=/kubed/.helm/config \
    HELM_DATA_HOME=/kubed/.helm/data
