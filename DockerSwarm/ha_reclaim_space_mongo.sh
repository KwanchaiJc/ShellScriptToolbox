#!/bin/bash

date=$(date '+%Y-%m-%d')
alertlogpath=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
pathscript=$(grep scriptspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
collection_names=(
 "insert_collection_name"
 "insert_collection_name"
)
conmongo=$(docker ps|grep insert_mongo_name|awk '{print $NF}')
exec_statequery=$(docker exec -it "$conmongo" mongo --eval 'printjson(rs.status().members.filter(m => m.stateStr == "PRIMARY")[0].name)' | grep -oE 'rs[0-9]')
conmongo_2=$(echo "$conmongo" | cut -d'.' -f1 | cut -d'_' -f2)

get_disk_space_stats() {
 echo "Disk space Statistics"
 du /opt/mongo/* | grep mongo | tee -a "$alertlogpath/reclaimspacemongodb.txt"
 echo "" | tee -a "$alertlogpath/reclaimspacemongodb.txt"
 du -h /opt/mongo/* | grep mongo | tee -a "$alertlogpath/reclaimspacemongodb.txt"
}

get_db_stats(){
 echo "Database space statistics"
 docker exec -it "$conmongo" mongo --eval "db.getSiblingDB('insert_db_name').stats();" | tee -a "$alertlogpath/reclaimspacemongodb.txt"
 echo "" | tee -a "$alertlogpath/reclaimspacemongodb.txt"
 docker exec -it "$conmongo" mongo --eval "db.getSiblingDB('insert_db_name').getCollectionNames().forEach(function(c) {var stats = db.getSiblingDB('insert_db_name').getCollection(c).stats(); print(c + ': ' + stats.size + ' bytes');});" | tee -a "$alertlogpath/reclaimspacemongodb.txt"
}

senario(){
 #Before Reclaim space
 get_disk_space_stats
 get_db_stats

 echo "" | tee -a "$alertlogpath/reclaimspacemongodb.txt"
 echo "Initial reclaim space mongodb" >> "$alertlogpath/reclaimspacemongodb.txt"

 for collection_name in "${collection_names[@]}"
  do
   echo "$collection_name" >> "$alertlogpath/reclaimspacemongodb.txt"
   docker exec -it "$conmongo" mongo --eval "db.getSiblingDB('insert_db_name').runCommand({compact: '$collection_name'});" | tee -a "$alertlogpath/reclaimspacemongodb.txt"
 done

 echo "" | tee -a "$alertlogpath/reclaimspacemongodb.txt"

 #After Reclaim space
 get_disk_space_stats
 get_db_stats
}

if [ "$conmongo_2" == "$exec_statequery" ]; then
 echo "This is primary" >> "$alertlogpath/reclaimspacemongodb.txt"
 #Execute command to change primary node
 docker exec -it "$conmongo" mongo --eval 'rs.stepDown()' >> "$alertlogpath/reclaimspacemongodb.txt"
 senario >> "$alertlogpath/reclaimspacemongodb.txt"
 if [ -f "$alertlogpath/reclaimspacemongodb.txt" ]; then
  topic_error="Recalaim_space_mongodb"
  python2.7 $pathscript/sendmail.py $topic_error $alertlogpath/reclaimspacemongodb.txt
  rm $alertlogpath/reclaimspacemongodb.txt
 fi
else
 echo "Not primary" >> "$alertlogpath/reclaimspacemongodb.txt"
 senario >> "$alertlogpath/reclaimspacemongodb.txt"
 if [ -f "$alertlogpath/reclaimspacemongodb.txt" ]; then
  topic_error="Recalaim_space_mongodb"
  python2.7 $pathscript/sendmail.py $topic_error $alertlogpath/reclaimspacemongodb.txt
  rm $alertlogpath/reclaimspacemongodb.txt
 fi
fi
