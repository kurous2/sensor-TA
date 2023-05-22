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

TOKEN=$(echo "${DATA}" | grep -o '"access_token":[^,}]*' | cut -d'"' -f4)
API_ENDPOINT2="http://10.10.10.250:8002/api/sensors"
if [ ! -z `docker compose --project-directory $script_dir ps -q --filter status=running | grep $(docker compose --project-directory $script_dir ps -q snort)` ]; then
response=$(curl -f -s -X POST \
	"${API_ENDPOINT2}/heartbeat" \
	-H 'Content-Type: application/json' \
	-H 'Authorization: Bearer '${TOKEN}'' \
	-d '{"uuid":"'${UUID}'"}')
fi
