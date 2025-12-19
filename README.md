# Autonomy Lab Dev Environment Bootstrap

Standardized development environment setup for Cooper Union Autonomy Lab. This repository contains modular installation scripts and verification tooling to create a consistent dependency baseline across lab computers running Ubuntu 22.04.

## Overview

This bootstrap workflow installs and configures the core autonomy stack:

- ROS 2 Humble
- Gazebo Simulator (Harmonic/Garden/Fortress)
- ROS-Gazebo Bridge
- Docker
- SSH Server
- CARLA Dependencies
- MuJoCo

## Requirements

- Ubuntu 22.04 LTS (fresh install recommended)
- Sudo privileges
- Internet connection

## Quick Start

### Installation
```bash
git clone https://github.com/<your-username>/autonomy-dev-bootstrap.git
cd autonomy-dev-bootstrap
chmod +x setup.sh
./setup.sh
```

The setup script runs each layer script in sequence. The process may take 30-60 minutes depending on network speed and machine performance. You may be prompted for your sudo password during installation.

### Verification

After installation completes, verify that all components were installed correctly:
```bash
chmod +x 99_verify_autonomy_lab.sh
./99_verify_autonomy_lab.sh
```

The verification script checks each component and reports PASS, WARN, or FAIL status. Review any warnings or failures and consult the relevant layer script for troubleshooting.

## Repository Structure
```
autonomy-dev-bootstrap/
├── setup.sh                    # Main entry point - runs all layer scripts
├── 00_base.sh                  # Locale + core dev tools
├── 01_ros2_humble.sh           # ROS 2 Humble
├── 02_gazebo_sim.sh            # Gazebo Simulator
├── 03_ros_gz_bridge.sh         # ROS ↔ Gazebo bridge
├── 04_docker.sh                # Docker engine + compose
├── 05_ssh_server.sh            # OpenSSH server
├── 06_carla_deps.sh            # CARLA prerequisites
├── 07_mujoco.sh                # MuJoCo
├── 08_simplerenv.sh            # Reserved for future use
├── 99_verify_autonomy_lab.sh   # Post-install verification
└── README.md
```

## Script Details

| Script | Function | Notes |
|--------|----------|-------|
| `00_base.sh` | Locale + core dev tools | Sets UTF-8 locale, installs build essentials, Python, git |
| `01_ros2_humble.sh` | ROS 2 Humble | Adds ROS apt source, installs desktop packages and rosdep |
| `02_gazebo_sim.sh` | Gazebo Simulator | Installs gz-harmonic → fallback gz-garden → fallback ignition-fortress |
| `03_ros_gz_bridge.sh` | ROS ↔ Gazebo bridge | Installs ros-humble-ros-gz |
| `04_docker.sh` | Docker | Installs Docker engine and compose plugin |
| `05_ssh_server.sh` | SSH | Installs and enables OpenSSH server |
| `06_carla_deps.sh` | CARLA prerequisites | Installs build dependencies only; does **not** install CARLA itself |
| `07_mujoco.sh` | MuJoCo | Installs OpenGL dependencies and Python mujoco package |
| `08_simplerenv.sh` | Placeholder | Reserved for future environment tooling |

## Selective Installation

If you only need specific components, you can run individual scripts instead of the full setup:
```bash
chmod +x 00_base.sh 01_ros2_humble.sh
./00_base.sh
./01_ros2_humble.sh
```

**Note:** Some scripts depend on others. The base script (`00_base.sh`) should always be run first.

## Verification Script Output

The verification script (`99_verify_autonomy_lab.sh`) checks:

- Locale configuration (UTF-8)
- Base commands (curl, git, python3, build tools)
- ROS 2 Humble installation and `ros2` command
- Gazebo detection (gz, ign, or classic gazebo)
- ROS-Gazebo bridge package
- Docker installation and daemon status
- SSH server installation and service status
- CARLA dependency packages
- MuJoCo Python import

Output format:
```
[PASS] Component installed correctly
[WARN] Component may need attention (e.g., logout required for docker group)
[FAIL] Component missing or misconfigured
```

## Known Limitations

### Testing Status

Each individual shell script has been run and executed without issues on Ubuntu 22.04. However, the complete end-to-end workflow has not yet been tested on a fully wiped computer with a fresh Ubuntu installation. While each component works in isolation, edge cases or dependency ordering issues may surface when running the entire installation sequence from scratch. If you encounter issues during a clean install, please open an issue.

### CARLA Installation

The `06_carla_deps.sh` script installs prerequisites only. CARLA itself and Unreal Engine must be installed separately following the [official CARLA documentation](https://carla.readthedocs.io/).

### Docker Group

After running `04_docker.sh`, you must log out and log back in for docker group permissions to take effect. The verification script will warn about this if needed.

### SSH on School Network

School Wi-Fi may block incoming SSH connections. See lab documentation for approved workarounds.

## Maintenance

This repository requires periodic updates as dependencies evolve:

- Ubuntu 22.04 EOL planning
- ROS distribution updates
- CARLA/MuJoCo version changes
- Package repository changes

**Last updated:** December 18, 2025

## Contributing

When modifying scripts:

1. Test changes on Ubuntu 22.04
2. Update comments to explain what each command does
3. Update this README if adding new scripts or changing functionality
4. Run the verification script to confirm nothing broke

## Contact

Ryan Chung — Autonomy Lab (VIP)
Email: seokwoo.chung@cooper.edu

