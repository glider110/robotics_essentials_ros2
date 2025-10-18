FROM osrf/ros:humble-desktop-full

# Setup user for GUI to work without xhost
ARG UNAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN usermod -aG sudo ${UNAME}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${UNAME}

# Create a custom ros2 overlay workspace and workspace for exercises
ENV ROS2_WS=/home/user/ros2_ws
RUN mkdir -p ${ROS2_WS}/src


# Disable terminal interaction for apt
ENV DEBIAN_FRONTEND=noninteractive

# Make default shell in Dockerfile bash instead of sh
SHELL ["/bin/bash", "-c"]

# Clear any host-injected proxies to avoid 127.0.0.1:7890 failures during build
ENV http_proxy= \
    https_proxy= \
    HTTP_PROXY= \
    HTTPS_PROXY= \
    all_proxy= \
    no_proxy=

# Ensure rosdep/rosdistro index uses the official source (avoid flaky mirrors during build)
ENV ROSDISTRO_INDEX_URL=https://raw.githubusercontent.com/ros/rosdistro/master/index-v4.yaml

# Copy andino requirement files and install dependencies
COPY docker/andino_requirements.txt .
RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y $(cat andino_requirements.txt)
RUN sudo rm andino_requirements.txt

# Install Gazebo Fortress (HTTPS + signed-by keyring, with retry)
RUN sudo mkdir -p /usr/share/keyrings && \
        curl -fsSL https://packages.osrfoundation.org/gazebo.gpg | sudo gpg --dearmor -o /usr/share/keyrings/gazebo-archive-keyring.gpg && \
        echo "deb [signed-by=/usr/share/keyrings/gazebo-archive-keyring.gpg] https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | \
            sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
        sudo apt-get update && \
        sudo apt-get -o Acquire::Retries=5 install -y --no-install-recommends ignition-fortress || \
        (echo 'ignition-fortress failed, trying gz-fortress if available'; \
         sudo apt-get -o Acquire::Retries=5 install -y --no-install-recommends gz-fortress || true)

# Install dependencies
RUN sudo apt-get update && \
        sudo apt-get install -y --no-install-recommends \
            ros-$ROS_DISTRO-navigation2 \
            ros-$ROS_DISTRO-turtle-nest \
            ros-humble-tf-transformations \
            ca-certificates curl wget \
        && sudo apt-get clean && \
        sudo rm -rf /var/lib/apt/lists/*
# Install andino_gz and other packages with their dependencies
COPY ./packages/ ${ROS2_WS}/src

# Note: andino_gz package should be mounted from host packages/ directory

# Install dependencies and build (preseed rosdep sources + retry)
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends python3-rosdep && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    sudo mkdir -p /etc/ros/rosdep/sources.list.d && \
            printf '%s\n' \
                'yaml https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/base.yaml' \
                'yaml https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/python.yaml' \
                'yaml https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/ruby.yaml' \
      | sudo tee /etc/ros/rosdep/sources.list.d/20-default.list > /dev/null && \
    cd ${ROS2_WS} && \
    # Ensure no proxy environment variables are present (empty values can break Python URL handling)
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy NO_PROXY no_proxy && \
    for i in {1..5}; do rosdep update && break || (echo "rosdep update failed, retry $i" && sleep 5); done && \
    rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO} && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    colcon build --symlink-install



# Source ROS workspace automatically when new terminal is opened
RUN echo ". /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo ". ${ROS2_WS}/install/setup.bash" >> ~/.bashrc

WORKDIR /home/user/ros2_ws

# Source ROS in the main terminal
COPY docker/ros_entrypoint.sh /ros_entrypoint.sh

# Source ROS in the main terminal
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash"]