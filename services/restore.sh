#!/bin/bash

COMPOSE_FILE_PATH=./docker-compose.yml
PROJECT_NAME=services
BACKUP_PATH=~/backup

backup_timestamp=$1

function restore_volume {
  volume_name=$1
  
  backup_folder="$BACKUP_PATH/$backup_timestamp"
  
  docker run --rm -v $volume_name:/data -v $backup_folder:/backup ubuntu bash -c "cd /data && tar -zxvf /backup/$volume_name.tar"
}

echo "Stopping running containers"
docker compose -f $COMPOSE_FILE_PATH stop

echo "Mounting volumes and performing restore..."
volumes=($(docker volume ls -f name=$PROJECT_NAME | awk '{if (NR > 1) print $2}'))
for v in "${volumes[@]}"
do
  echo "Restoring volume $v..."
  restore_volume $v
done

echo "Restarting containers"
docker compose -f $COMPOSE_FILE_PATH start
