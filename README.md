# Snort Sensor

## Mata Elang v1.1 Update

- Upgrade Snort version to Snort version 3
- Add IPv6 Compatibility
- Add Snort version 3 data parser
- ARM Support compatibility for Snort version 3 and Snort parser


## Prerequisites

- [x] Install Docker Engine
- [x] Install docker-compose

All required files for sensor installation are placed in `snort` folder

- Dockerfile file is for building the Docker Image. No additional configuration needed.

- local.rules File is an example for implemented snort rules in the docker image. if you want to try the sensor using the example local.rules file, disable the commented line inside the file first.

- pulledpork.conf file is for Snort configuration file to download the rule using the oinkcode. you should define the oinkcode inside the file.

```
oinkcode = <your-oinkcode>
``` 

- snort.lua file is for Snort configuration file that define all variables needed by Snort application. No additional configuration needed.

- start.sh file is an entrypoint file inside the docker image which applied to start the execution of the snort application.

## Usage

In the docker-compose.yml file there are 2 docker image services inside:

1. snort

Snort image is a docker image for Mata Elang snort version 3. There is a change that should be made in the environtment variable. Inside the environtment variable you should configure the "NETWORK_INTERFACE" with your monitored network interface.
```
environment:
     - NETWORK_INTERFACE=<YOUR_MONITORED_NETWORK_INTERFACE>
```

2. snort-parser

Snort-parser image is a docker image for Mata Elang snort version 3 JSON data parser. you could modify the MQTT environtment variable in the docker service

```
environment:
    - MQTT_HOST=192.168.1.1
    - MQTT_PORT=1883
    - MQTT_USERNAME=username
    - MQTT_PASSWORD=password
    - SENSOR_ID=<machine-id>
    - MQTT_TOPIC=mataelang/sensor/v3/<sensor-id>
    - SNORT_ALERT_FILE_PATH=/var/log/snort/alert_json.txt
```

**1. Start Snort services and confirm the services are up**

There is a wrapper shell script called run.sh for docker compose, please run as root.

```
$ sudo su -
# ./run.sh
```
This equals to
```
$ sudo su -
# docker-compose up -d
```

### Check running service

```
# docker-compose ps
```
Please ensure that Snort and Snort-parser container statuses are UP


Check with:
```
# crontab -l
```

### Configure Snort Rule Auto Update (Optional)
This command will add a line into crontab:

```
# ./run.sh set-automation
```

Check with:
```
# crontab -l
```

To disable auto updater:
```
# ./run.sh unset-automation
```

### Manually Run Snort Rule Update

```
# ./run.sh update-rules
```

### Get PCAP Files

Usually, the default volume for snort_data is located in `/var/lib/docker/volumes/mataelang-sensor_snort_data/_data`. But, if you couldn't find it, you can check the mount point path using this command:

```bash
$ docker volume ls
DRIVER    VOLUME NAME
local     mataelang-sensor_snort_data
```

```bash
$ docker volume inspect mataelang-sensor_snort_data | grep Mountpoint
        "Mountpoint": "/var/lib/docker/volumes/mataelang-sensor_snort_data/_data",
```

After you can find the mount point path, you can go through the directory using the `sudo` command or `root` user and copy the PCAP files.

```bash
$ sudo ls /var/lib/docker/volumes/mataelang-sensor_snort_data/_data/ | grep pcap
log.pcap.1671680168
```

### Change PCAP Log Limit Size

You can change the PCAP log limit size from Snort configuration file in `snort/snort.lua`. Here is the example configuration:
```lua
log_pcap = {
    limit = 100, -- in MBytes
}
```

### Change Max number of PCAP Log to Keep on Disk

You can also limit the number of PCAP log file that stored on Disk by change the value of `MAX_PCAP_FILES` (snort-parser) in `docker-compose.yaml` file.

Example: 
```yaml
    ...
      - MQTT_HOST=192.168.1.1
      - MQTT_PORT=1883
      # - MQTT_USERNAME=username
      # - MQTT_PASSWORD=password
      - MAX_PCAP_FILES=5
    ...
```