#!/bin/bash

# 机器人仿真启动脚本
set -e

echo "正在启动 Andino 机器人仿真..."

# 进入 docker 目录
cd "$(dirname "$0")/docker"

# 启动容器（如果还没有运行）
echo "启动 Docker 容器..."
docker compose up -d

# 等待容器完全启动
sleep 2

# 在容器中启动 Andino Gazebo 仿真
echo "启动 Andino Gazebo 仿真..."
docker exec -it robotics_essentials_ros2 bash -c "source /opt/ros/humble/setup.bash && source /home/user/ros2_ws/install/setup.bash && ros2 launch andino_gz andino_gz.launch.py"