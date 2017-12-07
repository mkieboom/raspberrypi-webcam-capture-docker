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

  echo "Pushing new file ('$filename') event on MapR Streams using Kafka REST API"
  curl -X POST -H "Content-Type: application/vnd.kafka.json.v1+json" \
     --data '{"records":[{"value": {"filename" : "'$filename'" , "path" : "'$outputfolder'"}  }]}' \
     http://$MAPR_USER:$MAPR_PASSWORD@$MAPR_KAFKA_REST_HOST:8082/topics/%2F$MAPR_STREAM%3A$MAPR_STREAM_TOPIC

  # Once processed, remove the file to avoid the filesystem to fload
  echo "Removing file '$filename'"
  rm -rf $outputfolder/$filename

done;



