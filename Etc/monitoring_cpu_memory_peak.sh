#!/bin/bash

date=$(date '+%Y%m%d_%H%M')
alertlogpath=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
scriptspath=$(grep scriptspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')

check_cpu_mem_peak(){
 threshold=100
 arrVar+=( "$(docker ps --format "{{.Names}}")" )
 arrSplit=($(echo "${arrVar[@]}" | tr ' ' '\n'))

 for loopcontainername in "${arrSplit[@]}"; do
  checkcpu=$(docker stats "$loopcontainername" --no-stream --format  "{{.CPUPerc}}")
  checkmem=$(docker stats "$loopcontainername" --no-stream --format  "{{.MemPerc}}")
  checknetio=$(docker stats "$loopcontainername" --no-stream --format  "{{.NetIO}}")
  checkblockio=$(docker stats "$loopcontainername" --no-stream --format  "{{.BlockIO}}")
  
  clear_cpu=$(echo "$checkcpu" | sed "s/%//")
  roundcpu=$(printf "%.0f" "$clear_cpu")

  #Check mem peak
  clear_mem=$(echo "$checkmem" |  sed "s/%//")
  roundmem=$(printf "%.0f" "$clear_mem")
  
  if [ "$roundcpu" -gt $threshold ] || [ "$roundmem" -gt $threshold ]; then
    echo "Timestamp:" "$date" "| Containername:" "$loopcontainername" "| CPU:" "$checkcpu" "| Memory:" "$checkmem" "| NetIO:" "$checknetio" "| BlockIO:" "$checkblockio" >> "$alertlogpath/resource_report.txt"
  fi
 done
}

check_cpu_mem_peak
