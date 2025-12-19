#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Name: Ryan Chung, Autonomy Lab
#
# 01_ros2_humble.sh — ROS 2 Humble (Ubuntu 22.04)
#
# Packages installed:
#   - ros-humble-desktop
#   - ros-dev-tools
#   - python3-rosdep
#
# Also downloads/installs:
#   - ros2-apt-source_<version>_<codename>_all.deb
###############################################################################

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then SUDO="sudo"; fi

# 1) Ensure universe is enabled (ROS prereq)
$SUDO apt-get update -y
$SUDO apt-get install -y software-properties-common curl
$SUDO add-apt-repository universe -y

# 2) Install ROS 2 apt source package (official)
ROS_APT_SOURCE_VERSION="$(
  curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest \
  | grep -F "tag_name" | awk -F\" '{print $4}'
)"
UBUNTU_CODENAME="$(
  . /etc/os-release
  echo "${UBUNTU_CODENAME:-${VERSION_CODENAME}}"
)"

curl -L -o /tmp/ros2-apt-source.deb \
  "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.${UBUNTU_CODENAME}_all.deb"
$SUDO dpkg -i /tmp/ros2-apt-source.deb

# 3) Update/upgrade then install ROS
$SUDO apt-get update -y
$SUDO apt-get upgrade -y
$SUDO apt-get install -y ros-humble-desktop ros-dev-tools

# 4) rosdep (recommended for workspace dependency resolution)
$SUDO apt-get install -y python3-rosdep
if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
  $SUDO rosdep init
fi
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  sudo -u "${SUDO_USER}" rosdep update
else
  rosdep update
fi

# 5) Add ROS sourcing to user's bashrc (non-destructive)
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
BASHRC="${TARGET_HOME}/.bashrc"
if [[ -f "${BASHRC}" ]] && ! grep -q "/opt/ros/humble/setup.bash" "${BASHRC}"; then
  echo "source /opt/ros/humble/setup.bash" >> "${BASHRC}"
fi

echo "✅ 01_ros2_humble.sh complete"
