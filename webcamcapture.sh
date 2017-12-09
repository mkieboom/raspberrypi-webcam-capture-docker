#!/bin/bash

while true; do
  # Set the output folder and filename to store the image
  outputfolder=/tmp/webcam/
  filename=webcam-$(date +"%Y%m%d-%H%M%S").jpg


  # Check if the webcam is connected
  #if [ -f "/dev/video0" ]
  #then
    # Capture a webcam image
    fswebcam -d /dev/video0 --resolution 640x480 --jpeg 85 --frames 1 $outputfolder/$filename

    # Check if the webcam successfully created an image, if so push it to MapR
    if [ -f "$outputfolder/$filename" ]
    then
      # Push the captured image to MapR-FS
      curl -i -X PUT "http://$MAPR_HOST:14000/webhdfs/v1/webcam/$filename?op=CREATE&user.name=mapr"
      curl -i -X PUT -T $outputfolder/$filename -H "Content-Type:application/octet-stream" "http://$MAPR_HOST:14000/webhdfs/v1/webcam/$filename?op=CREATE&overwrite=true&permission=444&data=true&user.name=mapr"

      # Push an event on MapR Streams to tell a new image has been uploaded
      echo "Pushing new file ('"$filename"') event on MapR Streams using Kafka REST API"
      curl -X POST -H "Content-Type: application/vnd.kafka.json.v1+json" \
         --data '{"records":[{"value": {"filename" : "'$filename'" , "path" : "'$outputfolder'"}  }]}' \
         http://$MAPR_USER:$MAPR_PASSWORD@$MAPR_HOST:8082/topics/%2F$MAPR_STREAM%3A$MAPR_STREAM_TOPIC
      echo "\nPush finished"

      # Once processed, remove the file to avoid the filesystem to fload
      echo "Removing file '"$filename"'"
      rm -rf $outputfolder/$filename
    else
      echo "No webcam image found. Is the webcam connected? Pausing for 5 seconds"
	  sleep 5
    fi
  #else
  #	echo "No webcam connected to /dev/video0. Pausing for 5 seconds"
  #  sleep 5
  #fi
done;
