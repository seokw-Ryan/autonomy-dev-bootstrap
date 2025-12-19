#!/bin/bash

#===============================================================================
# Autonomy Lab Dev Environment Bootstrap
# Main setup script - orchestrates installation of all dependencies
#
# Usage: ./setup.sh
#
# This script runs each layer script in sequence to install the full
# autonomy stack on Ubuntu 22.04.
#
# Author: Ryan Chung
# Last updated: December 18, 2025
#===============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (so we can find layer scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#-------------------------------------------------------------------------------
# Helper functions
#-------------------------------------------------------------------------------

print_header() {
    echo ""
    echo -e "${BLUE}===============================================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}===============================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

run_script() {
    local script_name=$1
    local script_path="${SCRIPT_DIR}/${script_name}"
    
    if [[ -f "$script_path" ]]; then
        print_header "Running ${script_name}"
        chmod +x "$script_path"
        if bash "$script_path"; then
            print_success "${script_name} completed successfully"
        else
            print_error "${script_name} failed"
            exit 1
        fi
    else
        print_warning "${script_name} not found, skipping..."
    fi
}

#-------------------------------------------------------------------------------
# Pre-flight checks
#-------------------------------------------------------------------------------

print_header "Autonomy Lab Dev Environment Bootstrap"

echo "This script will install the following components:"
echo "  - Base tools (locale, build essentials, Python, git)"
echo "  - ROS 2 Humble"
echo "  - Gazebo Simulator"
echo "  - ROS-Gazebo Bridge"
echo "  - Docker"
echo "  - SSH Server"
echo "  - CARLA Dependencies"
echo "  - MuJoCo"
echo ""

# Check for Ubuntu 22.04
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" != "ubuntu" ]] || [[ "$VERSION_ID" != "22.04" ]]; then
        print_warning "This script is designed for Ubuntu 22.04"
        print_warning "Detected: $PRETTY_NAME"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    print_warning "Could not detect OS version"
fi

# Check for sudo
if ! sudo -v; then
    print_error "This script requires sudo privileges"
    exit 1
fi

# Confirm installation
read -p "Proceed with installation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

#-------------------------------------------------------------------------------
# Run layer scripts in order
#-------------------------------------------------------------------------------

START_TIME=$(date +%s)

run_script "00_base.sh"
run_script "01_ros2_humble.sh"
run_script "02_gazebo_sim.sh"
run_script "03_ros_gz_bridge.sh"
run_script "04_docker.sh"
run_script "05_ssh_server.sh"
run_script "06_carla_deps.sh"
run_script "07_mujoco.sh"
run_script "08_simplerenv.sh"

#-------------------------------------------------------------------------------
# Post-installation summary
#-------------------------------------------------------------------------------

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

print_header "Installation Complete"

echo "Total time: ${MINUTES}m ${SECONDS}s"
echo ""
echo "Next steps:"
echo "  1. Log out and log back in (required for docker group permissions)"
echo "  2. Run the verification script to confirm installation:"
echo ""
echo "     ./99_verify_autonomy_lab.sh"
echo ""
echo "  3. Source ROS 2 in your shell (add to ~/.bashrc for persistence):"
echo ""
echo "     source /opt/ros/humble/setup.bash"
echo ""

print_warning "Note: CARLA itself is not installed. Only dependencies were set up."
print_warning "See https://carla.readthedocs.io/ for CARLA installation instructions."

echo ""
print_success "Autonomy Lab environment setup complete!"