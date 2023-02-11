FROM mataelang/snort-base:3.1.47.0

COPY snort/pulledpork.conf /usr/local/etc/pulledpork/pulledpork.conf
COPY snort/snort.lua /usr/local/etc/snort/snort.lua
COPY snort/local.rules /usr/local/etc/rules/local.rules
COPY snort/start.sh /usr/local/bin/start-sensor.sh
COPY snort/pulledpork.py /usr/local/bin/pulledpork.py

RUN chmod u+x /usr/local/bin/start-sensor.sh && \
    chmod u+x /usr/local/bin/pulledpork.py && \
    pulledpork.py -c /usr/local/etc/pulledpork/pulledpork.conf

CMD [ "/usr/local/bin/start-sensor.sh" ]