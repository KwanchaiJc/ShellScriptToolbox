#!/bin/bash

check_docker_status() {
 date=$(date '+%Y%m%d_%H%M')
 alertlogpath=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
 pathgreplogscript=$(grep scriptspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
 containers=$(docker ps --format "Container name: {{.Names}} | Status: {{.Status}}")
 IFS=$'\n' read -rd '' -a container_array <<< "$containers"
 if [ "${#container_array[@]}" -ne 15 ]; then
  for container_info in "${container_array[@]}"; do
   echo "$container_info" >> "$alert_log_path/docker_runing_issue_$date.log"
  done

  ps aux --sort -pmem >> "$alert_log_path/process_$date.log"
  topic_error="Docker_was_down"
  python "$pathgreplogscript/sendmail.py" "$topic_error" "$alert_log_path/docker_runing_issue_$date.log"

  sh "$pathgreplogscript/grepcontainerlog.sh"
 fi
}

check_docker_status
