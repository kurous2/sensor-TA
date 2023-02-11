FROM mataelang/snort-base:3.1.47.0

COPY pulledpork.conf /usr/local/etc/pulledpork/pulledpork.conf
COPY snort.lua /usr/local/etc/snort/snort.lua
COPY local.rules /usr/local/etc/rules/local.rules

# Patch for path changes of Februray 2023
COPY ./src/pulledpork.py.feb23 /usr/local/bin/pulledpork.py
RUN chmod +x /usr/local/bin/pulledpork.py

RUN pulledpork.py -c /usr/local/etc/pulledpork/pulledpork.conf

COPY start.sh /usr/local/bin/start-sensor.sh
RUN chmod u+x /usr/local/bin/start-sensor.sh

CMD [ "/usr/local/bin/start-sensor.sh" ]
