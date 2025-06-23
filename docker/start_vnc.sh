#!/bin/bash
# start_vnc.sh
docker compose up 
sleep 2
docker compose exec robotics_essentials_ros2 bash -c "vncserver -kill :1; vncserver :1 -geometry 1920x1080 -depth 24 -localhost no"
echo "VNC 已启动，连接地址: localhost:5901，密码: vncpass123"