#!/bin/bash
API_ENDPOINT="http://10.10.10.250:8001/api/sensors"
API_ENDPOINT2="http://10.10.10.250:8001/api/sensors"
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

STATUS=$(echo "${DATA}" | grep -o '"status":[^,}]*' | cut -d'"' -f4)
ID=$(echo "${DATA}" | grep -o '"id":[^,}]*' | cut -d: -f2)
TOKEN=$(echo "${DATA}" | grep -o '"access_token":[^,}]*' | cut -d'"' -f4)
chmod +x $script_dir/script.sh
if [[ "$STATUS" = "update on progress" ]]; then
$script_dir/script.sh >> $script_dir/run.log 2>&1
response=$(curl -f -s -X PATCH \
	"${API_ENDPOINT2}/update_status/${ID}" \
	-H 'Content-Type: application/json' \
	-H 'Authorization: Bearer '${TOKEN}'' \
	-d '{"status":"updated"}')
fi
