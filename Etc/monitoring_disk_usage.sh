#!/bin/bash

date=$(date '+%Y%m%d_%H%M')
alertlogpath=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
scriptspath=$(grep scriptspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')

check_disk_usage() {
 threshold=95
 paths=(
  "insert_path"
  "insert_path"
 )
 
 for loop_path in "${paths[@]}"; do
  usage=$(df -m $loop_path | grep -v Filesystem | awk '{ print $5 }')
  usage_percent=${usage%\%}
  if [ "$usage_percent" -gt "$threshold" ]; then
   echo "Urgent directory using excessive disk space" >> $alertlogpath/urgent_directory_excessive_disk_space.log
   df -mkh $loop_path | grep -v Filesystem >> $alertlogpath/urgent_directory_excessive_disk_space.log
   if [ -f "$alertlogpath/urgent_directory_excessive_disk_space.log" ]; then
    percent=$usage_percent
    path=$loop_path
    topic_error="Urgent_${path}_directory_excessive_amount_of_disk_space_exceeding_${percent}%" 
    python2.7 $scriptspath/sendmail.py $topic_error $alertlogpath/urgent_directory_excessive_disk_space.log
    rm $alertlogpath/urgent_directory_excessive_disk_space.log
   fi
  fi
 done
}

check_disk_usage
