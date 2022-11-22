FROM ghcr.io/abc-irobotics/ros_base:main

# install build tools
RUN apt-get update && apt-get install -y \
      sox \
      ffmpeg \
      libcairo2 \
      libcairo2-dev \
      texlive-full \
      python3-gi-cairo && \
      apt update && apt upgrade -y && \
      apt install -y \
      python3-pip \
      python3-gi \
      gobject-introspection \
      gir1.2-gtk-3.0 && \
      rm -rf /var/lib/apt/lists/* && \
      pip install \
      torch==1.10.2 \
      pandas==1.4.1 \
      requests==2.27.1 \
      torchvision==0.11.3 \
      tqdm==4.62.3 \
      matplotlib==3.5.1 \
      numpy==1.22.2 \
      opencv-contrib-python==4.5.5.64 \
      transforms3d==0.3.1 \
      scipy==1.8.0 \
      seaborn==0.11.2 \
      cairocffi \
      pycairo==1.14.0

# rebuild underlay workspace
RUN cd /usr/underlay_ws && \
      catkin config \
      --extend /opt/ros/$ROS_DISTRO && \
    catkin build && \
    sed --in-place --expression \
      '$isource "/usr/underlay_ws/devel/setup.bash"' \
      /ros_entrypoint.sh

# clone ros packages
ENV ROS_WS /usr/catkin_ws

WORKDIR $ROS_WS

RUN git -C src clone \
      https://github.com/ABC-iRobotics/bark_msgs && \
      git -C src clone \
            https://github.com/ABC-iRobotics/camera_projections && \
      git -C src clone \
            https://github.com/ABC-iRobotics/slidebot_detection && \
      git -C src clone \
            https://github.com/ABC-iRobotics/orient_correction && \
      git -C src clone \
            https://github.com/ABC-iRobotics/yolo_bounding_box_detection && \
      git -C src clone \
            https://github.com/ABC-iRobotics/bark_slidebot && \
      catkin config \
      --extend /usr/underlay_ws/devel && \
    catkin build && \
      sed --in-place --expression \
      '$isource "$ROS_WS/devel/setup.bash"' \
      /ros_entrypoint.sh && \
      git -C src clone \
      https://github.com/ultralytics/yolov5 && \
      cd src/yolov5 && \
      git checkout 15e82d296720d4be344bf42a34d60ffd57b3eb28 && \
      pip install -r requirements.txt && \
      echo "source /usr/catkin_ws/devel/setup.bash" >> /etc/bash.bashrc && \
      echo "export ROS_MASTER_URI=http://192.168.1.150:11311/" >> /etc/bash.bashrc && \
      echo "export ROS_IP=192.168.1.150" >> /etc/bash.bashrc

CMD ["bash"]