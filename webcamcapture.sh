#!/bin/bash
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "while true; do sleep 30; done;" ]

while true; do
  outputfolder=/tmp/webcam/
  filename=webcam-%Y%m%d-%H%M%S.jpg

  # Capture a webcam image
  fswebcam -d /dev/video0 --resolution 640x480 --jpeg 85 --frames 1 $outputfolder/$filename

  # Push the captured image to MapR-FS
  curl -i -X PUT "http://192.168.168.1:14000/webhdfs/v1/webcam/$filename?op=CREATE&user.name=mapr"
  curl -i -X PUT -T $outputfolder/$filename -H "Content-Type:application/octet-stream" "http://192.168.168.1:14000/webhdfs/v1/webcam/$filename?op=CREATE&overwrite=true&permission=550&data=true&user.name=mapr"

done;



