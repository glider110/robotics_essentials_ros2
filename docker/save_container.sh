#!/bin/bash

# 保存Docker容器为新镜像的脚本
# Save Docker Container as New Image Script

set -e

# 配置变量
CONTAINER_NAME="robotics_essentials_ros2"
NEW_IMAGE_NAME="robotics_essentials_ros2_saved"
NEW_IMAGE_TAG="latest"
COMPOSE_FILE="docker-compose.yaml"
COMPOSE_SAVED_FILE="docker-compose-saved.yaml"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== 保存Docker容器为新镜像脚本 ===${NC}"

# 检查容器是否正在运行
echo -e "${YELLOW}检查容器状态...${NC}"
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${RED}错误: 容器 '$CONTAINER_NAME' 未运行${NC}"
    echo -e "${YELLOW}请先启动容器: docker compose up -d${NC}"
    exit 1
fi

echo -e "${GREEN}容器 '$CONTAINER_NAME' 正在运行${NC}"

# 获取容器ID
CONTAINER_ID=$(docker ps --filter "name=$CONTAINER_NAME" --format "{{.ID}}")
echo -e "${BLUE}容器ID: $CONTAINER_ID${NC}"

# 询问用户是否确认保存
echo -e "${YELLOW}即将保存容器为新镜像: $NEW_IMAGE_NAME:$NEW_IMAGE_TAG${NC}"
read -p "是否继续? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}操作已取消${NC}"
    exit 0
fi

# 提交容器为新镜像
echo -e "${YELLOW}正在保存容器为新镜像...${NC}"
docker commit $CONTAINER_ID $NEW_IMAGE_NAME:$NEW_IMAGE_TAG

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 镜像保存成功: $NEW_IMAGE_NAME:$NEW_IMAGE_TAG${NC}"
    
    # 清理悬空镜像 (dangling images)
    echo -e "${YELLOW}清理悬空镜像...${NC}"
    DANGLING_IMAGES=$(docker images -f "dangling=true" -q)
    if [ ! -z "$DANGLING_IMAGES" ]; then
        docker rmi $DANGLING_IMAGES
        echo -e "${GREEN}✓ 已清理悬空镜像${NC}"
    else
        echo -e "${BLUE}ℹ 没有悬空镜像需要清理${NC}"
    fi
else
    echo -e "${RED}✗ 镜像保存失败${NC}"
    exit 1
fi

# 创建新的docker-compose文件
echo -e "${YELLOW}创建新的docker-compose配置...${NC}"

cat > $COMPOSE_SAVED_FILE << EOF
services:
  robotics_essentials_ros2:
    image: $NEW_IMAGE_NAME:$NEW_IMAGE_TAG
    # build 配置已注释，现在直接使用保存的镜像
    # build:
    #   context: ..
    #   dockerfile: docker/Dockerfile
    container_name: $CONTAINER_NAME
    stop_signal: SIGINT
    network_mode: host
    privileged: true
    stdin_open: true
    #runtime: nvidia
    tty: true
    user: user
    volumes:
      - ../packages:/home/user/ros2_ws/src
      - /tmp/.X11-unix:/tmp/.X11-unix
      - /dev/dri:/dev/dri
    devices:
      - /dev/dri:/dev/dri
    environment:
      #- NVIDIA_VISIBLE_DEVICES=all # Makes all NVIDIA devices visible to the container
      #- NVIDIA_DRIVER_CAPABILITIES=all # Grants all NVIDIA driver capabilities to the container
      #- __NV_PRIME_RENDER_OFFLOAD=1 # Enables NVIDIA PRIME render offload
      #- __GLX_VENDOR_LIBRARY_NAME=nvidia # Specifies the GLX vendor library to use (NVIDIA)
      - DISPLAY
      - QT_X11_NO_MITSHM=1
      - ROS_DOMAIN_ID=42
    command: bash
EOF

echo -e "${GREEN}✓ 新的docker-compose配置已创建: $COMPOSE_SAVED_FILE${NC}"

# 询问是否替换原有的docker-compose文件
echo -e "${YELLOW}是否要替换原有的 $COMPOSE_FILE 文件?${NC}"
echo -e "${YELLOW}(建议先备份原文件)${NC}"
read -p "替换原文件? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 备份原文件
    cp $COMPOSE_FILE "${COMPOSE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✓ 原文件已备份${NC}"
    
    # 替换文件
    mv $COMPOSE_SAVED_FILE $COMPOSE_FILE
    echo -e "${GREEN}✓ docker-compose.yaml 已更新${NC}"
else
    echo -e "${BLUE}保留了两个文件:${NC}"
    echo -e "  - $COMPOSE_FILE (原文件)"
    echo -e "  - $COMPOSE_SAVED_FILE (新配置)"
fi

# 显示镜像信息
echo -e "${BLUE}=== 镜像信息 ===${NC}"
docker images | grep -E "(REPOSITORY|$NEW_IMAGE_NAME)"

echo -e "${GREEN}=== 操作完成 ===${NC}"
echo -e "${BLUE}下次启动容器请使用:${NC}"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "  docker compose up -d"
else
    echo -e "  docker compose -f $COMPOSE_SAVED_FILE up -d"
fi

echo -e "${YELLOW}💡 镜像管理提示:${NC}"
echo -e "  清理所有悬空镜像: ${BLUE}docker image prune${NC}"
echo -e "  清理所有未使用镜像: ${BLUE}docker image prune -a${NC}"
echo -e "  查看镜像大小: ${BLUE}docker images --format \"table {{.Repository}}\\t{{.Tag}}\\t{{.Size}}\"${NC}"
echo -e "  删除特定镜像: ${BLUE}docker rmi <镜像ID或名称>${NC}"