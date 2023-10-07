#!/bin/bash

COMPOSE_FILE_PATH=./docker-compose.yml
PROJECT_NAME=services
BACKUP_PATH=~/backup

function backup_volume {
  volume_name=$1
  backup_folder=$2
  
  docker run --rm -v $volume_name:/data -v $backup_folder:/backup ubuntu bash -c "cd /data && tar -zcvf /backup/$volume_name.tar ."
}

echo "Stopping running containers"
docker compose -f $COMPOSE_FILE_PATH stop

current_timestamp=$(date +%Y-%m-%d_%H-%M-%S)
backup_subfolder="$BACKUP_PATH/$current_timestamp"
echo "Creating backup folder $backup_subfolder..."
mkdir -p "$backup_subfolder"

echo "Mounting volumes and performing backup..."
volumes=($(docker volume ls -f name=$PROJECT_NAME | awk '{if (NR > 1) print $2}'))
for v in "${volumes[@]}"
do
  echo "Backup for volume $v..."
  backup_volume $v $backup_subfolder
done

echo "Restarting containers"
docker compose -f $COMPOSE_FILE_PATH start
