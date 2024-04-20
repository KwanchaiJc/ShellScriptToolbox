#!/bin/bash

date=$(date '+%Y%m%d_%H%M')
alertlogpath=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
scriptspath=$(grep scriptspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')

cnt_files=$(find $alertlogpath/ -type f -name "*.log" | wc -l)
flag_enable_script=$(grep flag_enable_script /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')

#Performance reports
if [ -f "$alertlogpath/resource_report.txt" ]; then
 topic_error="Peak_resource_usage_docker_container_report"
 python $scriptspath/sendmail.py $topic_error $alertlogpath/resource_report.txt
 rm "$alertlogpath/resource_report.txt"
fi

