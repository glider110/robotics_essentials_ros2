#!/bin/bash
set -e

# 设置环境变量
export ROS2_WS=${ROS2_WS:-/home/user/ros2_ws}
export WORKSPACE=${WORKSPACE:-/home/user/workspace}

echo "🚀 初始化ROS2开发环境..."

# 确保ROS2工作空间目录存在
mkdir -p ${ROS2_WS}/src

# 创建软链接到挂载的packages目录
if [ -d "${WORKSPACE}/packages" ]; then
    echo "📦 设置packages软链接..."
    for package_dir in ${WORKSPACE}/packages/*/; do
        if [ -d "$package_dir" ]; then
            package_name=$(basename "$package_dir")
            target_link="${ROS2_WS}/src/${package_name}"
            
            # 如果目标不存在或不是软链接，创建软链接
            if [ ! -L "$target_link" ]; then
                # 如果是目录，先删除
                if [ -d "$target_link" ]; then
                    rm -rf "$target_link"
                fi
                ln -sf "$package_dir" "$target_link"
                echo "  ✓ ${package_name}"
            fi
        fi
    done
fi

# 源ROS环境
echo "🔧 加载ROS环境..."
. "/opt/ros/${ROS_DISTRO}/setup.bash"

# 如果ROS2工作空间已构建，则源它
if [ -f "${ROS2_WS}/install/setup.bash" ]; then
    . "${ROS2_WS}/install/setup.bash"
    echo "✅ ROS2工作空间已加载"
else
    echo "⚠️  ROS2工作空间未构建，请运行: cd /home/user/ros2_ws && colcon build"
fi

echo "🎯 环境初始化完成！"
echo "📁 当前目录: $(pwd)"
echo "🔗 Git仓库状态:"
if [ -d "${WORKSPACE}/.git" ]; then
    cd ${WORKSPACE}
    git status --porcelain | head -3
    echo "   ..."
else
    echo "   未检测到Git仓库"
fi

exec "$@"