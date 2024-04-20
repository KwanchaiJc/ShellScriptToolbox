#!/bin/bash
 
check_selinux_status(){

check_selinux_status=$(getenforce | grep -i "enforcing" | wc -l)
date=$(date '+%Y%m%d_%H%M')
alertlogpath=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
scriptspath=$(grep scriptspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')

if [ $check_selinux_status -eq 1 ];
 then
  echo "SElinux status : " $(getenforce) > $alertlogpath/selinux_issue_$date.log
  topic_error="SElinux_is_enforcing"
  python $scriptspath/sendmail.py $topic_error $alertlogpath/selinux_issue_$date.log
fi
}

check_selinux_status
