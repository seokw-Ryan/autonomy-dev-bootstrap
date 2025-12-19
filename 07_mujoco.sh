#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Name: Ryan Chung, Autonomy Lab
#
# 07_mujoco.sh — MuJoCo (common setup: system deps + Python package)
#
# Packages installed:
#   - python3-pip, python3-venv
#   - libgl1-mesa-dev
#   - libosmesa6-dev
#   - patchelf
#
# Python packages installed:
#   - mujoco
###############################################################################

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then SUDO="sudo"; fi

# 1) System deps for OpenGL contexts + wheel compatibility
$SUDO apt-get update -y
$SUDO apt-get install -y python3-pip python3-venv libgl1-mesa-dev libosmesa6-dev patchelf

# 2) Install MuJoCo python package (system pip)
python3 -m pip install --upgrade pip
python3 -m pip install mujoco

echo "✅ 07_mujoco.sh complete"
