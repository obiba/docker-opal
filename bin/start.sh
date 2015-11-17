#!/bin/bash

# check if 1st run. Then configure properties.
if [ -n "$AGATE_PORT_8444_TCP_ADDR" -a -e /opt/opal/bin/first_run.sh ]
    then
    sed s/localhost:8444/$AGATE_PORT_8444_TCP_ADDR:$AGATE_PORT_8444_TCP_PORT/g /etc/opal/opal-config.properties | \
     sed s/#org.obiba.realm.url/org.obiba.realm.url/g > /tmp/opal-config.properties
	mv -f /tmp/opal-config.properties /etc/opal/opal-config.properties
	chown -R opal:adm /etc/opal
fi

# Start opal as a service
service opal start

# Wait for the opal server to be up and running
sleep 5

# check if 1st run. Then configure database.
if [ -e /opt/opal/bin/first_run.sh ]
    then
    /opt/opal/bin/first_run.sh
    mv /opt/opal/bin/first_run.sh /opt/opal/bin/first_run.sh.done
fi

# Tail the log
tail -f /var/log/opal/opal.log

# Stop opal service
service opal stop