#!/bin/bash

script_dir="$( dirname -- "$( readlink -f -- "$0"; )"; )"
script_path="$script_dir/run.sh"
pulledpork_path="$script_dir/snort"

UUID=$(cat "${script_dir}/.env" \
	| grep "UUID" \
	| awk -F"=" '{split($2,a," ");gsub(/"/, "", a[1]);print a[1]}')

API_ENDPOINT="http://10.10.10.250:8001/api/sensors"

# Send the cURL request and store the response in a variable
response=$(curl -s -X POST "${API_ENDPOINT}/login" \
-H 'Content-Type: application/json' \
-d '{"uuid":"'${UUID}'"}' --max-time 5)

if [[ $? -ne 0 ]]; then
  echo "Connection failed or timed out"
  exit 1
fi

NAME=$(echo "${response}" | grep -o '"name":[^,}]*' | cut -d'"' -f4)

if [[ $NAME -eq "" ]]; then
  printf "Invalid UUID\n"
  exit 1
fi

#add check if response is valid. important

YAML_FILE="$script_dir/docker-compose.yaml"

HOME_NET_FILE="$script_dir/snort/snort.lua"
# Set the variable name and new value

PROTECTED_SUBNET=$(echo "${response}" | grep -o '"protected_subnet":[^,}]*' | cut -d'"' -f4 | sed 's/\\\//\//g')
NET_INT=$(echo "${response}" | grep -o '"network_interface":[^,}]*' | cut -d'"' -f4)
#NAME=$(echo "${response}" | grep -o '"name":[^,}]*' | cut -d'"' -f4)
MQTT_HOST=$(echo "${response}" | grep -o '"mqtt_ip":"[^"]*' | cut -d'"' -f4)
MQTT_PORT=$(echo "${response}" | grep -o '"mqtt_port":[^,}]*' | cut -d'"' -f4)
OINKCODE=$(echo "$response" | grep -o '"oinkcode":[^,}]*' | cut -d'"' -f4)
MQTT_USERNAME="mataelang"
MQTT_PASSWORD="mataelang"
#echo $MQTT_HOST
sed -i "s/\(- NETWORK_INTERFACE=\).*/\1${NET_INT}/" "${YAML_FILE}"
sed -i "s/\(- MQTT_HOST=\).*/\1${MQTT_HOST}/" "${YAML_FILE}"
sed -i "s/\(- MQTT_PORT=\).*/\1${MQTT_PORT}/" "${YAML_FILE}"
sed -i "s/\(- MQTT_USERNAME=\).*/\1${MQTT_USERNAME}/" "${YAML_FILE}"
sed -i "s/\(- MQTT_PASSWORD=\).*/\1${MQTT_PASSWORD}/" "${YAML_FILE}"
sed -i "s/\(- SENSOR_ID=\).*/\1${NAME}/" "${YAML_FILE}"



sed -i "s|HOME_NET = '.*'|HOME_NET = '$PROTECTED_SUBNET'|" "${HOME_NET_FILE}"

FILE=$pulledpork_path/pulledpork.conf
if [ ! -f "$FILE" ]; then
    cp "$pulledpork_path/pulledpork.conf.example" "$pulledpork_path/pulledpork.conf"
fi
PORK_FILE="$script_dir/snort/pulledpork.conf"
sed -i "s/oinkcode = .*/oinkcode = $OINKCODE/" "${PORK_FILE}"

docker_compose_path="docker-compose"

# Check if Docker Engine already installed
if ! command -v docker &>/dev/null; then
    echo "You need to install Docker to continue."
    exit 1
fi

if ! docker compose version &>/dev/null; then
	# if return > 0, set path to old docker compose
	docker_compose_path="docker-compose"
    
	# Check if old version of Docker Compose exists
    if ! command -v "$docker_compose_path" &>/dev/null; then
        echo "Docker Compose command not found."
        echo "You need to install Docker Compose command to continue."
        exit 1
    fi    
fi

docker_compose_path="${docker_compose_path} --project-directory $script_dir"
#echo $docker_compose_path

$docker_compose_path -f $script_dir/docker-compose.yaml up -d

chmod +x $script_dir/checkcron.sh

$script_dir/checkcron.sh

