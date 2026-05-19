#!/bin/bash
set -euo pipefail

if command -v crush &>/dev/null; then
  echo "Crush is already installed: $(crush --version 2>/dev/null || echo 'unknown version')"
  exit 0
fi

echo "==> Adding Charm RPM repository..."
cat <<'REPO' > /etc/yum.repos.d/charm.repo
[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key
REPO

echo "==> Installing Crush and dependencies..."
microdnf install -y --nodocs crush git-core

echo "==> Cleaning package cache..."
microdnf clean all

echo "==> Setting up default configuration..."
CRUSH_CONFIG_DIR="${HOME}/.config/crush"
mkdir -p "${CRUSH_CONFIG_DIR}"

if [ ! -f "${CRUSH_CONFIG_DIR}/crush.json" ] && [ -f /projects/crush.json ]; then
  cp /projects/crush.json "${CRUSH_CONFIG_DIR}/crush.json"
  echo "Copied crush.json template to ${CRUSH_CONFIG_DIR}/crush.json"
fi

echo "==> Crush installation complete."
crush --version 2>/dev/null || echo "Crush installed (version check unavailable)"
