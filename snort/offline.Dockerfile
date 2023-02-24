FROM mataelang/snort-base:3.1.47.0
ARG RULE_FILENAME=snortrules-snapshot-31470.tar.gz

COPY snort/pulledpork.conf /usr/local/etc/pulledpork/pulledpork.conf
COPY snort/snort.lua /usr/local/etc/snort/snort.lua
COPY snort/local.rules /usr/local/etc/rules/local.rules
COPY snort/start.sh /usr/local/bin/start-sensor.sh
COPY rules/${RULE_FILENAME} /tmp/

RUN chmod u+x /usr/local/bin/start-sensor.sh && \
    pulledpork.py -f /tmp/${RULE_FILENAME} -c /usr/local/etc/pulledpork/pulledpork.conf && \
    rm /tmp/${RULE_FILENAME}

CMD [ "/usr/local/bin/start-sensor.sh" ]