FROM ghcr.io/abc-irobotics/ros_base:main

# install build tools
RUN apt-get update && apt-get install -y \
      sox \
      ffmpeg \
      libcairo2 \
      libcairo2-dev \
      texlive-full
RUN apt update && apt upgrade -y && \
    apt install -y \
      python3-pip \
      python3-gi \
      gobject-introspection \
      gir1.2-gtk-3.0 && \
    rm -rf /var/lib/apt/lists/*

RUN pip install \
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

RUN apt-get update && apt-get install -y python3-gi-cairo

ENV UNDERLAY_WS /usr/underlay_ws

WORKDIR $UNDERLAY_WS

# rebuild underlay workspace
RUN catkin config \
      --extend /opt/ros/$ROS_DISTRO && \
    catkin build

# source ros package from entrypoint
RUN sed --in-place --expression \
      '$isource "$UNDERLAY_WS/devel/setup.bash"' \
      /ros_entrypoint.sh

# clone ros packages
ENV ROS_WS /usr/catkin_ws

WORKDIR $ROS_WS

RUN git -C src clone \
      https://github.com/ABC-iRobotics/bark_msgs

RUN git -C src clone \
      https://github.com/ABC-iRobotics/camera_projections

RUN git -C src clone \
      https://github.com/ABC-iRobotics/slidebot_detection

RUN git -C src clone \
      https://github.com/ABC-iRobotics/orient_correction

RUN git -C src clone \
      https://github.com/ABC-iRobotics/yolo_bounding_box_detection

RUN git -C src clone \
      https://github.com/ABC-iRobotics/bark_slidebot

# build catkin workspace
RUN catkin config \
      --extend /usr/underlay_ws/devel && \
    catkin build

# source ros package from entrypoint
RUN sed --in-place --expression \
      '$isource "$ROS_WS/devel/setup.bash"' \
      /ros_entrypoint.sh

RUN git -C src clone \
      https://github.com/ultralytics/yolov5 && \
      cd src/yolov5 && \
      git checkout 15e82d296720d4be344bf42a34d60ffd57b3eb28 && \
      pip install -r requirements.txt

RUN echo "source /usr/catkin_ws/devel/setup.bash" >> /etc/bash.bashrc
RUN echo "export ROS_MASTER_URI=http://192.168.1.150:11311/" >> /etc/bash.bashrc
RUN echo "export ROS_IP=192.168.1.150" >> /etc/bash.bashrc

WORKDIR $ROS_WS

CMD ["bash"]