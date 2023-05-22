#!/bin/bash

# Install yq
script_dir="$( dirname -- "$( readlink -f -- "$0"; )"; )"
# Set the YAML file path
read -rp "Insert UUID : " UUID

if [ -z "$UUID" ]; then
  printf "UUID is Required\n"
  exit 1
fi

cat > $script_dir/.env <<EOL
UUID="${UUID}"
EOL

chmod +x $script_dir/script.sh

./script.sh
