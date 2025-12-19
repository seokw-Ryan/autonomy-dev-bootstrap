#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Name: Ryan Chung, Autonomy Lab
#
# 02_gazebo_sim.sh — Gazebo Sim (new Gazebo) via OSRF repo
#
# Packages installed (one of these, depending on availability):
#   - gz-harmonic  OR
#   - gz-garden    OR
#   - ignition-fortress
#
# Plus repo tooling:
#   - curl, gnupg, lsb-release
###############################################################################

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then SUDO="sudo"; fi

# 1) Prereqs
$SUDO apt-get update -y
$SUDO apt-get install -y curl gnupg lsb-release

# 2) Add OSRF Gazebo repo keyring + apt source
$SUDO install -m 0755 -d /usr/share/keyrings
curl -fsSL https://packages.osrfoundation.org/gazebo.gpg \
  | $SUDO gpg --dearmor -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] \
https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
| $SUDO tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

# 3) Install Gazebo Sim (prefer newest meta pkg if present)
$SUDO apt-get update -y
$SUDO apt-get install -y gz-harmonic \
  || $SUDO apt-get install -y gz-garden \
  || $SUDO apt-get install -y ignition-fortress

echo "✅ 02_gazebo_sim.sh complete"
