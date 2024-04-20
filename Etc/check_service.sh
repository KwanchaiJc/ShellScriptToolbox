#!/bin/bash

date=$(date '+%Y%m%d_%H%M')
alertlogpath=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
scriptspath=$(grep scriptspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')

cnt_files=$(find $alertlogpath/ -type f -name "*.log" | wc -l)
flag_enable_script=$(grep flag_enable_script /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')

#Script will be stopped if flag_enabled_script is false and log file more than 4
if [ $flag_enable_script == true ] && [ "$cnt_files" -lt 4 ];
 then
  script_paths=(
   "$scriptspath/monitoring_selinux.sh"
   "$scriptspath/monitoring_firewall.sh"
   "$scriptspath/monitoring_docker.sh"
   "$scriptspath/monitoring_cpu_memory_peak.sh"
   "$scriptspath/monitoring_disk_usage.sh"
)
 for script_path in "${script_paths[@]}"; do
    . "$script_path"
 done
fi
