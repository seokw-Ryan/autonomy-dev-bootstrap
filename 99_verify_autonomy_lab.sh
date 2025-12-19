#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Name: Ryan Chung, Autonomy Lab
#
# 99_verify_autonomy_lab.sh — Verify Autonomy Lab dependencies on Ubuntu 22.04
#
# What this tests:
#   - Locale set to en_US.UTF-8
#   - Base tools exist (curl, git, etc.)
#   - ROS 2 Humble installed and ros2 command works
#   - Gazebo installed (new Gazebo: gz / ign, or classic gazebo)
#   - ROS ↔ Gazebo bridge package installed (ros-humble-ros-gz)
#   - Docker installed + daemon reachable (may require logout/login for non-root)
#   - SSH server installed + service status
#   - CARLA *dependencies* present (NOT CARLA itself)
#   - MuJoCo python package import works (NOT a full graphics test)
###############################################################################

PASS=0
FAIL=0
WARN=0

green() { echo -e "\033[0;32m$*\033[0m"; }
red()   { echo -e "\033[0;31m$*\033[0m"; }
yellow(){ echo -e "\033[0;33m$*\033[0m"; }
blue()  { echo -e "\033[0;34m$*\033[0m"; }

ok()   { green "✅ $*"; PASS=$((PASS+1)); }
bad()  { red   "❌ $*"; FAIL=$((FAIL+1)); }
warn() { yellow "⚠️  $*"; WARN=$((WARN+1)); }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

have_pkg() {
  # dpkg -s exits nonzero if not installed
  dpkg -s "$1" >/dev/null 2>&1
}

section() {
  echo
  blue "========== $* =========="
}

###############################################################################
# 1) Locale check
###############################################################################
section "Locale"
if locale | grep -q "LANG=en_US.UTF-8" || locale | grep -q "en_US.UTF-8"; then
  ok "Locale looks set (en_US.UTF-8 appears in locale output)"
else
  bad "Locale does NOT look set to en_US.UTF-8 (run 00_base.sh locale steps)"
fi

###############################################################################
# 2) Base tools
###############################################################################
section "Base Tools"
for c in curl wget git python3 cmake ninja; do
  if have_cmd "$c"; then
    ok "Command exists: $c"
  else
    bad "Missing command: $c"
  fi
done

if have_cmd git && have_cmd git-lfs; then
  ok "Git LFS exists: $(git lfs version 2>/dev/null || echo 'git-lfs installed')"
else
  warn "git-lfs not found (needed for some large repos like CARLA assets)"
fi

###############################################################################
# 3) ROS 2 Humble
###############################################################################
section "ROS 2 Humble"
if [[ -f /opt/ros/humble/setup.bash ]]; then
  ok "Found /opt/ros/humble/setup.bash"
else
  bad "Missing /opt/ros/humble/setup.bash (ROS Humble not installed?)"
fi

# Source ROS environment for this test only
set +u
# shellcheck disable=SC1091
[[ -f /opt/ros/humble/setup.bash ]] && source /opt/ros/humble/setup.bash
set -u

if have_cmd ros2; then
  if ros2 --help >/dev/null 2>&1; then
    ok "ros2 command runs"
  else
    bad "ros2 command exists but failed to run"
  fi
else
  bad "ros2 command not found (ROS not sourced/installed)"
fi

# rosdep check (optional but recommended)
if have_cmd rosdep; then
  ok "rosdep exists"
else
  warn "rosdep not found (recommended: sudo apt install python3-rosdep)"
fi

###############################################################################
# 4) Gazebo (new or classic)
###############################################################################
section "Gazebo"
GAZEBO_FOUND=0

if have_cmd gz; then
  if gz sim --help >/dev/null 2>&1; then
    ok "New Gazebo found: gz (gz sim --help works)"
    GAZEBO_FOUND=1
  else
    warn "gz exists but gz sim --help failed"
  fi
fi

# Ignition/Gazebo Fortress sometimes uses `ign`
if [[ $GAZEBO_FOUND -eq 0 ]] && have_cmd ign; then
  if ign gazebo --help >/dev/null 2>&1; then
    ok "Ignition Gazebo found: ign gazebo (--help works)"
    GAZEBO_FOUND=1
  else
    warn "ign exists but ign gazebo --help failed"
  fi
fi

# Gazebo Classic uses `gazebo`
if [[ $GAZEBO_FOUND -eq 0 ]] && have_cmd gazebo; then
  if gazebo --version >/dev/null 2>&1; then
    ok "Gazebo Classic found: gazebo (--version works)"
    GAZEBO_FOUND=1
  else
    warn "gazebo exists but gazebo --version failed"
  fi
fi

if [[ $GAZEBO_FOUND -eq 0 ]]; then
  bad "No Gazebo command detected (gz/ign/gazebo). Run 02_gazebo_sim.sh (or install classic)."
fi

###############################################################################
# 5) ROS ↔ Gazebo bridge package
###############################################################################
section "ROS ↔ Gazebo Bridge"
if have_pkg ros-humble-ros-gz; then
  ok "Installed package: ros-humble-ros-gz"
else
  warn "ros-humble-ros-gz not installed (run 03_ros_gz_bridge.sh if you need ROS-Gazebo integration)"
fi

###############################################################################
# 6) Docker
###############################################################################
section "Docker"
if have_cmd docker; then
  ok "docker command exists: $(docker --version 2>/dev/null || echo 'docker present')"
else
  bad "docker command missing (run 04_docker.sh)"
fi

if have_cmd docker && docker compose version >/dev/null 2>&1; then
  ok "docker compose plugin works"
else
  warn "docker compose not working (may not be installed, or docker not set up)"
fi

# Daemon reachability: this may fail for non-root if user not in docker group yet.
if have_cmd docker; then
  if docker info >/dev/null 2>&1; then
    ok "Docker daemon reachable (docker info works)"
  else
    warn "Docker daemon NOT reachable as current user. If you just added user to docker group, log out/in or reboot. Or run with sudo."
  fi
fi

###############################################################################
# 7) SSH server
###############################################################################
section "SSH Server"
if have_pkg openssh-server; then
  ok "Installed package: openssh-server"
else
  bad "openssh-server not installed (run 05_ssh_server.sh)"
fi

# systemd check
if command -v systemctl >/dev/null 2>&1; then
  if systemctl is-enabled --quiet ssh 2>/dev/null; then
    ok "ssh service enabled"
  else
    warn "ssh service not enabled (sudo systemctl enable ssh)"
  fi

  if systemctl is-active --quiet ssh 2>/dev/null; then
    ok "ssh service active/running"
  else
    warn "ssh service not active (sudo systemctl start ssh)"
  fi
else
  warn "systemctl not available (cannot verify ssh service state)"
fi

###############################################################################
# 8) CARLA dependencies (NOT CARLA)
###############################################################################
section "CARLA Build Dependencies (NOT CARLA itself)"
carla_pkgs=(
  build-essential
  g++-12
  cmake
  ninja-build
  libvulkan1
  python3
  python3-dev
  python3-pip
  python3-venv
  autoconf
  wget
  curl
  rsync
  unzip
  git
  git-lfs
  libpng-dev
  libtiff5-dev
  libjpeg-dev
)

missing_carla=0
for p in "${carla_pkgs[@]}"; do
  if have_pkg "$p"; then
    ok "CARLA dep installed: $p"
  else
    missing_carla=1
    bad "Missing CARLA dep: $p"
  fi
done

if [[ $missing_carla -eq 0 ]]; then
  ok "All listed CARLA build deps appear installed"
else
  warn "Some CARLA build deps missing (run 06_carla_deps.sh)"
fi

warn "Reminder: this verifies CARLA *dependencies* only. CARLA itself (and Unreal Engine setup) is not installed here."

###############################################################################
# 9) MuJoCo
###############################################################################
section "MuJoCo"
if python3 -c "import mujoco; print(mujoco.__version__)" >/dev/null 2>&1; then
  ok "MuJoCo python package imports"
  echo "MuJoCo version: $(python3 -c "import mujoco; print(mujoco.__version__)" 2>/dev/null || true)"
else
  warn "MuJoCo python package not importable (run 07_mujoco.sh)"
fi

###############################################################################
# Summary
###############################################################################
section "Summary"
echo "PASS: $PASS"
echo "WARN: $WARN"
echo "FAIL: $FAIL"

if [[ $FAIL -gt 0 ]]; then
  red "❌ Some checks failed."
  exit 1
fi

yellow "✅ No hard failures. Review warnings if any."
exit 0

