# Webcam capture on a Raspberry Pi
#
# VERSION 0.1 - not for production, use at own risk
#
# Build the docker container:
# docker build -t mkieboom/raspberrypi-webcam-capture-docker .
#
# Run the docker container:
# docker run -it --device=/dev/video0:/dev/video0 -v /tmp/webcam:/tmp/webcam -e MAPR_USER=mapr -e MAPR_PASSWORD=mapr -e MAPR_HOST=192.168.1.221 -e MAPR_STREAM=imageclassification-stream -e MAPR_STREAM_TOPIC=webcam-image-events mkieboom/raspberrypi-webcam-capture-docker
#
#
# Using arm32v6 alpine as the base image
# For specific versions check: https://hub.docker.com/r/maprtech/pacc/tags/
FROM arm32v7/ubuntu

MAINTAINER mkieboom@mapr.com

# Update
RUN apt-get autoremove && apt-get -f install && apt-get update && apt-get upgrade -y

# Instal fswebcam to capture screenshots
RUN apt-get install -y curl fswebcam

# Add the webcamcapture.sh script and make it executable
ADD ./webcamcapture.sh /webcamcapture.sh
RUN chmod +x /webcamcapture.sh

CMD ./webcamcapture.sh 
#CMD /bin/bash

# Run fswebcam to capture webcam images
#CMD fswebcam -d /dev/video0 --resolution 640x480 --loop 1 --jpeg 85 --frames 5 /tmp/webcam/webcam-%Y%m%d-%H%M%S.jpg
