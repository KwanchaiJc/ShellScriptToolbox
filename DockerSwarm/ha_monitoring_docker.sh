#!/bin/bash

check_docker_status() {
 date=$(date '+%Y%m%d_%H%M')
 alertlogpath=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
 pathgreplogscript=$(grep scriptspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')

 docker service ls --format "{{.Name}}" | while read -r loopcontainername; do
  getreplicas=$(docker service ls --filter name="$loopcontainername" --format "{{.Replicas}}")
  extractlastrep="$(echo "$getreplicas" | awk -F'/' '{print $2}')"
  extractfirstrep="$(echo "$getreplicas" | awk -F'/' '{print $1}')"
  if [[ $extractfirstrep -ne $extractlastrep ]]; then
   echo "ID : $(docker service ls --filter name="$loopcontainername" --format "{{.ID}}") | NAME : $(docker service ls --filter name="$loopcontainername" --format "{{.Name}}") | REPLICAS : $(docker service ls --filter name="$loopcontainername" --format "{{.Replicas}}")" >> "$alertlogpath/containers_service_issue_$date.log"
  fi
 done

 if [ -f "$alertlogpath/containers_service_issue_$date.log" ]; then
  topic_error="Docker container was down"
  python $pathgreplogscript/sendmail.py $topic_error $alertlogpath/containers_service_issue_$date.log
  cd $pathgreplogscript && ./grepcontainerlog.sh
 fi
}

check_docker_status
