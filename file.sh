#!/bin/bash
API_ENDPOINT="http://10.10.10.250:8001/api/sensors"
API_ENDPOINT2="http://10.10.10.250:8002/api/sensors"
script_dir="$( dirname -- "$( readlink -f -- "$0"; )"; )"
folder_name=$(basename "$script_dir" | tr '[:upper:]' '[:lower:]')
UUID=$(cat "${script_dir}/.env" \
	| grep "UUID" \
	| awk -F"=" '{split($2,a," ");gsub(/"/, "", a[1]);print a[1]}')
url="http://10.10.10.250:8002/storage/sensor_rules/${UUID}/${UUID}.rules"
local=$(docker exec ${folder_name}_snort_1 cat /usr/local/etc/rules/local.rules)
#local=$(cat "$script_dir/snort/local.rules")
remoteContent=$(curl -s "$url")

remoteHash=$(echo -n "$remoteContent" | md5sum | awk '{ print $1 }')
localHash=$(echo -n "$local" | md5sum | awk '{ print $1 }')

docker_compose_path="docker-compose"
docker_compose_path="${docker_compose_path} --project-directory $script_dir"

DATA=$(curl -s -f -X POST \
	"${API_ENDPOINT}/login" \
	-H 'Content-Type: application/json' \
	-d '{"uuid":"'${UUID}'"}')

STATUS=$(echo "${DATA}" | grep -o '"status":[^,}]*' | cut -d'"' -f4)

ID=$(echo "${DATA}" | grep -o '"id":[^,}]*' | cut -d: -f2)
TOKEN=$(echo "${DATA}" | grep -o '"access_token":[^,}]*' | cut -d'"' -f4)
if [[ "$STATUS" = "rules uploaded" ]]; then
#echo "$remoteHash" 2>&1 >> remoteHash.log
#echo "$localHash" 2>&1 >> localHash.log
if [[ "$remoteContent" != "" ]]; then
if [[ "$remoteHash" != "$localHash" ]]; then
docker exec ${folder_name}_snort_1 sh -c 'echo "$1" > /usr/local/etc/rules/local.rules' -- "$remoteContent"
  docker exec ${folder_name}_snort_1 sh -c 'echo "$1" >> /usr/local/etc/rules/pulledpork.rules' -- "$remoteContent"
  $docker_compose_path -f $script_dir/docker-compose.yaml restart
 response=$(curl -f -s -X PATCH \
	"${API_ENDPOINT2}/update_status/${ID}" \
	-H 'Content-Type: application/json' \
	-H 'Authorization: Bearer '${TOKEN}'' \
	-d '{"status":"updated"}')
fi
fi
fi

