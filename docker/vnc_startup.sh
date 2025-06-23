#!/bin/bash

# VNC启动脚本
# 保存为 docker/vnc_startup.sh

set -e

# 清理残留的 VNC 进程和锁文件
vncserver -kill :1 > /dev/null 2>&1 || true
rm -rf /home/user/.vnc/*:1.pid /home/user/.vnc/*:1.log /tmp/.X1-lock /tmp/.X11-unix/X1

# 确保 .vnc 目录存在
mkdir -p /home/user/.vnc

# 创建 xstartup 文件（每次都重新创建确保内容正确）
cat <<EOF > /home/user/.vnc/xstartup
#!/bin/bash
# 设置环境变量
export USER=user
export HOME=/home/user
export DISPLAY=:1

# 启动 XFCE4 桌面环境
startxfce4
EOF
chmod +x /home/user/.vnc/xstartup

# 检查VNC密码是否已设置
if [ ! -f /home/user/.vnc/passwd ]; then
    echo "设置VNC密码..."
    export USER=user
    export HOME=/home/user
    # 使用 vncserver -passwd 选项设置密码
    echo "${VNC_PASSWORD:-123456}" | vncserver :1 -geometry 1920x1080 -depth 24 -passwd /home/user/.vnc/passwd -localhost no
    vncserver -kill :1
fi

# 启动VNC服务器
echo "启动VNC服务器..."
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no

# 显示连接信息
echo "==================================="
echo "VNC服务器已启动"
echo "连接地址: localhost:5901"
echo "密码: ${VNC_PASSWORD:-123456}"
echo "==================================="

# 保持脚本运行
tail -f /home/user/.vnc/*.log 