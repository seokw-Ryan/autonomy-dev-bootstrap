#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Name: Ryan Chung, Autonomy Lab
#
# 06_carla_deps.sh — CARLA build prerequisites (not CARLA itself)
#
# Packages installed:
#   - build-essential
#   - g++-12
#   - cmake
#   - ninja-build
#   - libvulkan1
#   - python3, python3-dev, python3-pip, python3-venv
#   - autoconf, wget, curl, rsync, unzip
#   - git, git-lfs
#   - libpng-dev, libtiff5-dev, libjpeg-dev
###############################################################################

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then SUDO="sudo"; fi

# 1) Install deps
$SUDO apt-get update -y
$SUDO apt-get install -y \
  build-essential g++-12 cmake ninja-build libvulkan1 \
  python3 python3-dev python3-pip python3-venv \
  autoconf wget curl rsync unzip \
  git git-lfs \
  libpng-dev libtiff5-dev libjpeg-dev

git lfs install --system || true

echo "✅ 06_carla_deps.sh complete"
echo "Note: Building CARLA also needs Unreal Engine setup (Epic/GitHub access)."
