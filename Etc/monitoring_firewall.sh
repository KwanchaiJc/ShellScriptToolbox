#!/bin/bash

check_firewall_status() {
date=$(date '+%Y%m%d_%H%M')
check_firewall_status=$(systemctl status firewalld.service | grep -i "active:" | grep -i "running" | wc -l)
alertlogpath=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
scriptspath=$(grep scriptspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')

if [ $check_firewall_status -eq 1 ];
 then
  echo "Firewalld status : " $(systemctl status firewalld.service) > $alertlogpath/firewall_issue_$date.log
  topic_error="Firewall_is_enabled"
  python $scriptspath/sendmail.py $topic_error $alertlogpath/firewall_issue_$date.log
fi
}

check_firewall_status
