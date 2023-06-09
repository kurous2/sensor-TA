#!/bin/bash
API_ENDPOINT="http://10.10.10.250:8001/api/sensors"
script_dir="$( dirname -- "$( readlink -f -- "$0"; )"; )"
UUID=$(cat "${script_dir}/.env" \
	| grep "UUID" \
	| awk -F"=" '{split($2,a," ");gsub(/"/, "", a[1]);print a[1]}')

DATA=$(curl -s -f -X POST \
	"${API_ENDPOINT}/login" \
	-H 'Content-Type: application/json' \
	-d '{"uuid":"'${UUID}'"}')

if [ $? -ne 0 ]; then
    echo "Sensor Not Registered"
    exit 1
fi
docker_compose_path="docker-compose"
docker_compose_path="${docker_compose_path} --project-directory $script_dir"

STATUS=$(echo "${DATA}" | grep -o '"status":[^,}]*' | cut -d'"' -f4)

if [[ "$STATUS" = "deleted" ]]; then
   rm "$script_dir/.env"
   crontab -l | grep -v cronupdate | crontab -
   $docker_compose_path -f $script_dir/docker-compose.yaml down -v
fi
