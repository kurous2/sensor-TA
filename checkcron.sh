#!/bin/bash
script_dir="$( dirname -- "$( readlink -f -- "$0"; )"; )"
update_path="$script_dir/cronupdate.sh"
heartbeat_path="$script_dir/heartbeat.sh"
upload_path="$script_dir/file.sh"
delete_path="$script_dir/delete.sh"

chmod +x $script_dir/cronupdate.sh
chmod +x $script_dir/heartbeat.sh
chmod +x $script_dir/file.sh
chmod +x $script_dir/delete.sh

# Set the cronjob command to check
CRONJOB_UPDATE="$update_path"
CRONJOB_HEARTBEAT="$heartbeat_path"
CRONJOB_UPLOAD="$upload_path"
CRONJOB_DELETE="$delete_path"

# Check if the cronjobs already exist
if crontab -l | grep -Fq "$CRONJOB_UPDATE;$CRONJOB_HEARTBEAT;$CRONJOB_UPLOAD;$CRONJOB_DELETE"; then
  echo "Cronjobs already exist"
else
  # Add the cronjobs if they don't exist
  (crontab -l ; echo "* * * * * $CRONJOB_UPDATE;$CRONJOB_HEARTBEAT;$CRONJOB_UPLOAD;$CRONJOB_DELETE") | crontab -
  echo "Cronjobs added"
fi
