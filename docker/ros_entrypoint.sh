#!/bin/bash
set -e

# Source base ROS env (prefer provided ROS_DISTRO, fallback to humble)
if [ -n "${ROS_DISTRO}" ] && [ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]; then
	. "/opt/ros/${ROS_DISTRO}/setup.bash"
elif [ -f "/opt/ros/humble/setup.bash" ]; then
	. "/opt/ros/humble/setup.bash"
fi

# Source overlay workspace if available
if [ -n "${ROS2_WS}" ] && [ -f "${ROS2_WS}/install/setup.bash" ]; then
	. "${ROS2_WS}/install/setup.bash"
fi

# Source exercises workspace if configured and built
if [ -n "${EXERCISES_WS}" ] && [ -f "${EXERCISES_WS}/install/setup.bash" ]; then
	. "${EXERCISES_WS}/install/setup.bash"
fi

exec "$@"