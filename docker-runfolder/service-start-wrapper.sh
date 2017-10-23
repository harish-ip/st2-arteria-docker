#!/bin/bash

runfolder_port=$1
# Start the first process
service ssh start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start ssh service: $status"
  exit $status
fi

# Start the second process
cd /opt/arteria-runfolder
runfolder-ws --port $runfolder_port --configroot config/
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start runfolder-ws: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container will exit with an error
# if it detects that either of the processes has exited.
# Otherwise it will loop forever, waking up every 60 seconds

while /bin/true; do
  ps aux |grep sshd |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep runfolder-ws |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they will exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit -1
  fi
  sleep 60
done
