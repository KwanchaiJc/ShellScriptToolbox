#!/bin/bash

backup_mongodb() {
 date=$(date '+%Y%m%d_%H%M')
 alertlogpath=$(grep logspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
 pathgreplogscript=$(grep scriptspath /opt/monitoring_docker/variables_control.txt | awk -F'=' '{print $2}')
 docker_mongo_name=$(docker ps|grep insert_mongo_container_name|awk '{print $NF}')
 mongo_container_backup_path="/insert_path_collect_backup_file"
 database_name="insert_db_name"
 exec_statequery=$(docker exec -it $docker_mongo_name mongo --eval 'printjson(rs.status().members.filter(m => m.stateStr == "PRIMARY")[0].name)' | grep -oE 'rs[0-9]')
 dirs=("/opt/mongo1/backup/" "/opt/mongo2/backup/" "/opt/mongo3/backup/")

 if [[ "$docker_mongo_name" =~ "$exec_statequery" ]]; then
  for dir in "${dirs[@]}"
  do
   if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
   fi
  done

  echo "Initiating database backup..." >> $alertlogpath/backup_mongodb_logs_$date.txt
  #Start backup script
  topic="Initiating_the_database_backup..."
  python $pathgreplogscript/sendmail.py $topic $alertlogpath/backup_mongodb_logs_$date.txt

  docker exec -u 0 $docker_mongo_name mongodump --archive=$mongo_container_backup_path"mongodb_$date.gz" --gzip --db "$database_name" >> $alertlogpath/backup_mongodb_logs_$date.txt 2>&1
  echo "Initiating the database backup is complete" >> $alertlogpath/backup_mongodb_logs_$date.txt
  
  if [ -f /opt/mongo1/backup/$mongo_container_backup_path"mongodb_$date.gz" ]; then
   topic="Initiating_the_database_backup_is_complete"
   python $pathgreplogscript/sendmail.py $topic $alertlogpath/backup_mongodb_logs_$date.txt
   rm $alertlogpath/backup_mongodb_logs_$date.txt
  else
   topic="Initiating_the_database_backup_is_incomplete"
   python $pathgreplogscript/sendmail.py $topic $alertlogpath/backup_mongodb_logs_$date.txt
   rm $alertlogpath/backup_mongodb_logs_$date.txt
  fi
 fi
}

backup_mongodb
