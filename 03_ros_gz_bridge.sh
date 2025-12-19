#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Name: Ryan Chung, Autonomy Lab
#
# 03_ros_gz_bridge.sh — ROS 2 Humble ↔ Gazebo bridge
#
# Packages installed:
#   - ros-humble-ros-gz
###############################################################################

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then SUDO="sudo"; fi

# 1) Install bridge (assumes ROS sources already set up)
$SUDO apt-get update -y
$SUDO apt-get install -y ros-humble-ros-gz

echo "✅ 03_ros_gz_bridge.sh complete"
