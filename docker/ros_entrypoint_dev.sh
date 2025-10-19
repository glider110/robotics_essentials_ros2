#!/bin/bash

# ROS2开发环境启动脚本
# Development Environment ROS2 Entrypoint Script

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== ROS2 开发环境初始化 ===${NC}"

# 设置环境变量
export ROS2_WS=/home/user/ros2_ws
export WORKSPACE=/home/user/workspace

# 创建软链接，将挂载的packages目录链接到ROS2工作空间
echo -e "${YELLOW}设置ROS2工作空间链接...${NC}"

# 确保ROS2工作空间目录存在
mkdir -p ${ROS2_WS}/src

# 如果src目录不是软链接且不为空，先备份
if [ -d "${ROS2_WS}/src" ] && [ ! -L "${ROS2_WS}/src" ]; then
    if [ "$(ls -A ${ROS2_WS}/src)" ]; then
        echo -e "${YELLOW}备份现有src目录...${NC}"
        sudo mv ${ROS2_WS}/src ${ROS2_WS}/src_backup_$(date +%Y%m%d_%H%M%S)
        mkdir -p ${ROS2_WS}/src
    fi
fi

# 创建软链接到挂载的packages目录
if [ ! -L "${ROS2_WS}/src/packages" ]; then
    ln -sf ${WORKSPACE}/packages ${ROS2_WS}/src/packages
    echo -e "${GREEN}✓ 创建软链接: ${ROS2_WS}/src/packages -> ${WORKSPACE}/packages${NC}"
fi

# 源ROS环境
echo -e "${YELLOW}源ROS环境...${NC}"
source /opt/ros/${ROS_DISTRO}/setup.bash

# 如果ROS2工作空间已构建，则源它
if [ -f "${ROS2_WS}/install/setup.bash" ]; then
    source ${ROS2_WS}/install/setup.bash
    echo -e "${GREEN}✓ 源ROS2工作空间${NC}"
fi

# 切换到工作空间目录
cd ${WORKSPACE}

echo -e "${GREEN}=== 开发环境就绪 ===${NC}"
echo -e "${BLUE}当前目录: $(pwd)${NC}"
echo -e "${BLUE}Git状态:${NC}"
git status --porcelain | head -5

# 显示有用的信息
echo -e "${YELLOW}"
echo "=== 常用命令 ==="
echo "构建ROS2包:    cd /home/user/ros2_ws && colcon build --symlink-install"
echo "源环境:        source /home/user/ros2_ws/install/setup.bash"
echo "运行SLAM:      ros2 launch andino_gz andino_gz.launch.py slam:=true"
echo "查看Git状态:   git status"
echo "==============${NC}"

# 执行传入的命令
exec "$@"