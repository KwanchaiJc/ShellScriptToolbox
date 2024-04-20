#!/bin/bash

path=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
host_name=$(hostname)
date=$(date '+%Y%m%d_%H%M')
listcontainername=$(docker ps --format "{{.Names}}")

IFS=$'\n' read -rd '' -a container_array <<< "$listcontainername"
for container_name in "${container_array[@]}"; do
 docker logs "$container_name" 2>&1 | tee $path/$date-$host_name-$container_name.txt
done
