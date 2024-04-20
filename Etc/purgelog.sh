#!/bin/bash

pathlog=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
cntfile=$(find $pathlog -type f -name "*.log" | wc -l)
if [ $cntfile -gt 3 ];
then
 find $pathlog -type f -name "*.log" | xargs rm
fi
