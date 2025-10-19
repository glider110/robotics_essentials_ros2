#!/bin/bash

# 在容器内执行ROS2命令的便捷脚本
# Convenient script to run ROS2 commands in container

set -e

CONTAINER_NAME="robotics_essentials_ros2"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查容器是否运行
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${RED}错误: 容器 '$CONTAINER_NAME' 未运行${NC}"
    echo -e "${YELLOW}请先启动容器: docker compose up -d${NC}"
    exit 1
fi

# 如果没有提供参数，显示帮助
if [ $# -eq 0 ]; then
    echo -e "${BLUE}=== ROS2容器命令执行器 ===${NC}"
    echo -e "${YELLOW}用法: $0 <ROS2命令>${NC}"
    echo ""
    echo -e "${BLUE}常用命令示例:${NC}"
    echo "  $0 \"ros2 topic list\""
    echo "  $0 \"ros2 launch andino_gz andino_gz.launch.py slam:=true\""
    echo "  $0 \"ros2 node list\""
    echo "  $0 \"colcon build --symlink-install\""
    echo "  $0 \"bash\"  # 进入交互式shell"
    exit 0
fi

# 构建完整的命令
FULL_COMMAND="source /opt/ros/humble/setup.bash"

# 如果ROS2工作空间已构建，则源它
FULL_COMMAND="$FULL_COMMAND && if [ -f /home/user/ros2_ws/install/setup.bash ]; then source /home/user/ros2_ws/install/setup.bash; fi"

# 添加用户命令
FULL_COMMAND="$FULL_COMMAND && $*"

echo -e "${BLUE}执行命令: ${YELLOW}$*${NC}"
echo -e "${BLUE}在容器: ${GREEN}$CONTAINER_NAME${NC}"

# 执行命令
docker exec -it $CONTAINER_NAME bash -c "$FULL_COMMAND"