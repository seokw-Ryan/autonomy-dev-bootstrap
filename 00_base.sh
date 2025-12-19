#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Name: Ryan Chung, Autonomy Lab
#
# 00_base.sh — Base OS dependencies (Ubuntu 22.04)
#
# Packages installed:
#   - locales
#   - ca-certificates
#   - curl
#   - wget
#   - gnupg
#   - lsb-release
#   - software-properties-common
#   - build-essential
#   - cmake
#   - ninja-build
#   - pkg-config
#   - python3, python3-dev, python3-pip, python3-venv
#   - git, git-lfs
#   - unzip, rsync, autoconf
###############################################################################

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then SUDO="sudo"; fi

# 1) Update apt
$SUDO apt-get update -y

# 2) Install locale support (UTF-8)
$SUDO apt-get install -y locales
$SUDO locale-gen en_US en_US.UTF-8
$SUDO update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# 3) Core networking + repo tooling
$SUDO apt-get install -y ca-certificates curl wget gnupg lsb-release software-properties-common

# 4) Build + Python tooling
$SUDO apt-get install -y build-essential cmake ninja-build pkg-config \
  python3 python3-dev python3-pip python3-venv \
  unzip rsync autoconf

# 5) Git + LFS
$SUDO apt-get install -y git git-lfs
git lfs install --system || true

# 6) Verify locale (optional)
locale || true

echo "✅ 00_base.sh complete"
