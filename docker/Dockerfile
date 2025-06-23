FROM osrf/ros:humble-desktop-full

# Setup user for GUI to work without xhost
ARG UNAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN usermod -aG sudo ${UNAME}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Disable terminal interaction for apt
ENV DEBIAN_FRONTEND=noninteractive

# Make default shell in Dockerfile bash instead of sh
SHELL ["/bin/bash", "-c"]

# Install TigerVNC and desktop environment as root
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-tools \
    fonts-dejavu-core \
    fonts-liberation2 \
    dbus-x11 \
    x11-apps \
    firefox \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directories as root
ENV ROS2_WS=/home/user/ros2_ws
ENV EXERCISES_WS=/home/user/exercises_ws
RUN mkdir -p ${ROS2_WS}/src ${EXERCISES_WS}/src && \
    chown -R ${UNAME}:${UNAME} /home/user

# Switch to user for remaining operations
USER ${UNAME}

# Copy andino requirement files and install dependencies
COPY docker/andino_requirements.txt .
RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y $(cat andino_requirements.txt)
RUN sudo rm andino_requirements.txt

# Install Gazebo Fortress
RUN sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
RUN sudo apt-get update
RUN sudo apt-get install ignition-fortress -y

# Install dependencies
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    ros-$ROS_DISTRO-navigation2 \
    ros-$ROS_DISTRO-turtle-nest \
    ros-humble-tf-transformations \
    && sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Install andino_gz and other packages with their dependencies
COPY ./packages/ ${ROS2_WS}/src
RUN cd ${ROS2_WS}/src && \
    git clone https://github.com/Ekumen-OS/andino_gz.git -b 0.1.1 && \
    sudo apt-get update && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd .. && \
    rosdep update && rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO} && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    colcon build --symlink-install

# Build exercises_ws
RUN cd ${EXERCISES_WS}/src && \
    sudo apt-get update && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd .. && \
    rosdep update && rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO} && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    colcon build --symlink-install

# Setup VNC configuration
RUN mkdir -p /home/user/.vnc && \
    echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > /home/user/.vnc/xstartup && \
    chmod +x /home/user/.vnc/xstartup && \
    echo 'session=xfce4\ngeometry=1920x1080\nlocalhost=no\nalwaysshared' > /home/user/.vnc/config

# Source ROS workspace automatically when new terminal is opened
RUN echo ". /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo ". ${EXERCISES_WS}/install/setup.bash" >> ~/.bashrc && \
    echo ". ${ROS2_WS}/install/setup.bash" >> ~/.bashrc

WORKDIR /home/user/exercises_ws

# Copy startup scripts
COPY docker/ros_entrypoint.sh /ros_entrypoint.sh
COPY docker/vnc_startup.sh /vnc_startup.sh
RUN sudo chmod +x /ros_entrypoint.sh /vnc_startup.sh

# Source ROS in the main terminal
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["/vnc_startup.sh"]