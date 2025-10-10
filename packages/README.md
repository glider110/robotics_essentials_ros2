# Packages Directory

This directory contains ROS 2 packages that will be mounted into the Docker container.

## Current packages:
- `create_plan_msgs/` - Custom message definitions for path planning
- `custom_nav2_planner/` - Custom navigation planner implementation

## Required package:
- `andino_gz/` - Andino robot Gazebo simulation package

### To add the andino_gz package:

```bash
cd packages
git clone --depth 1 https://github.com/Ekumen-OS/andino_gz.git -b 0.1.1
```

This package will be automatically mounted into the Docker container at `/home/user/ros2_ws/src/packages/` when using docker-compose.

## Usage

The packages in this directory are mounted as volumes in the Docker container, so any changes made locally will be reflected inside the container without needing to rebuild the Docker image.