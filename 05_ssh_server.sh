#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Name: Ryan Chung, Autonomy Lab
#
# 05_ssh_server.sh — SSH server
#
# Packages installed:
#   - openssh-server
###############################################################################

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then SUDO="sudo"; fi

# 1) Install
$SUDO apt-get update -y
$SUDO apt-get install -y openssh-server

# 2) Start + enable
$SUDO systemctl start ssh
$SUDO systemctl enable ssh

echo "✅ 05_ssh_server.sh complete"
