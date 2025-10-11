#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
TOOLS=("$@")

# Check if TOOLS array contains special packages with specific installs
if [[ " ${TOOLS[@]} " =~ " docker-ce-cli " ]]; then
  DOCKER_CLI_ENABLED="true"
else
  DOCKER_CLI_ENABLED="false"
fi
if [[ " ${TOOLS[@]} " =~ " 1password-cli " ]]; then
  OP_ENABLED="true"
else
  OP_ENABLED="false"
fi
if [[ " ${TOOLS[@]} " =~ " openvpn " ]]; then
  OPENVPN_ENABLED="true"
else
  OPENVPN_ENABLED="false"
fi

# make sure prerequisites are installed
apt-get update
apt-get install -y --no-install-recommends \
  apt-transport-https gpg lsb-release curl ca-certificates

# openvpn client setup
if [ "${OPENVPN_ENABLED}" = "true" ]; then
	# Remove the OPENVPN_CONFIG variable since we don't need it after is written to a file
	echo 'OPENVPN_CONFIG=""' >> /etc/environment
	echo "unset OPENVPN_CONFIG" | tee -a /etc/bash.bashrc > /etc/profile.d/999-unset-openvpn-config.sh
	if [ -d "/etc/zsh" ]; then echo "unset OPENVPN_CONFIG" >> /etc/zsh/zshenv; fi
fi

# if OP_ENABLED
if [ "${OP_ENABLED}" = "true" ]; then
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
    tee /etc/apt/sources.list.d/1password.list
  mkdir -p /etc/debsig/policies/AC2D62742012EA22/
  curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
  mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
fi

# if DOCKER_CLI_ENABLED
if [ "${DOCKER_CLI_ENABLED}" = "true" ]; then
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
fi

if [ ${#TOOLS[@]} -gt 0 ]; then
  apt-get update
  apt-get install -y --no-install-recommends "${TOOLS[@]}"
  # apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/library-scripts 
fi
