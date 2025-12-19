#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Name: Ryan Chung, Autonomy Lab
#
# 04_docker.sh — Docker Engine (official repo)
#
# Packages installed:
#   - docker-ce
#   - docker-ce-cli
#   - containerd.io
#   - docker-buildx-plugin
#   - docker-compose-plugin
#
# Plus repo tooling:
#   - ca-certificates, curl, gnupg
###############################################################################

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then SUDO="sudo"; fi

# 1) Prereqs
$SUDO apt-get update -y
$SUDO apt-get install -y ca-certificates curl gnupg

# 2) Docker keyring + repo
$SUDO install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /tmp/docker.asc
$SUDO mv /tmp/docker.asc /etc/apt/keyrings/docker.asc
$SUDO chmod a+r /etc/apt/keyrings/docker.asc

CODENAME="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
| $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3) Install Docker
$SUDO apt-get update -y
$SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4) Enable service
$SUDO systemctl enable --now docker || true

# 5) Add invoking user to docker group (requires logout/login to take effect)
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  $SUDO usermod -aG docker "${SUDO_USER}" || true
fi

echo "✅ 04_docker.sh complete"
