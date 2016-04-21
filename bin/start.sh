#!/bin/bash

# Make sure conf folder is available
if [ ! -d $OPAL_HOME/conf ]
    then
    mkdir -p $OPAL_HOME/conf
    cp -r /etc/opal/* $OPAL_HOME/conf
fi

# check if 1st run. Then configure properties.
if [ -n "$AGATE_PORT_8444_TCP_ADDR" -a -e /opt/opal/bin/first_run.sh ]
    then
    sed s/localhost:8444/$AGATE_PORT_8444_TCP_ADDR:$AGATE_PORT_8444_TCP_PORT/g $OPAL_HOME/conf/opal-config.properties | \
     sed s/#org.obiba.realm.url/org.obiba.realm.url/g > /tmp/opal-config.properties
	mv -f /tmp/opal-config.properties $OPAL_HOME/conf/opal-config.properties
fi

if [ -n "$RSERVER_PORT_6312_TCP_ADDR" -a -e /opt/opal/bin/first_run.sh ]
    then
    sed s/#org.obiba.opal.Rserve.host=/org.obiba.opal.Rserve.host=$RSERVER_PORT_6312_TCP_ADDR/g $OPAL_HOME/conf/opal-config.properties > /tmp/opal-config.properties
	mv -f /tmp/opal-config.properties $OPAL_HOME/conf/opal-config.properties
fi

if [ -e /opt/opal/bin/first_run.sh ]
    then
    adminpw=$(echo -n $OPAL_ADMINISTRATOR_PASSWORD | xargs java -jar /usr/share/opal-*/tools/lib/obiba-password-hasher-*-cli.jar)
    cat $OPAL_HOME/conf/shiro.ini | sed -e "s/^administrator\s*=.*,/administrator=$adminpw,/" > /tmp/shiro.ini && \
          mv /tmp/shiro.ini $OPAL_HOME/conf/shiro.ini
fi

chown -R opal:adm $OPAL_HOME/conf

# Start opal
/usr/share/opal/bin/opal &

# Wait for the opal server to be up and running
echo "Waiting for Opal to be ready..."
until opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m GET /system/databases &> /dev/null
do
    sleep 5
done

# check if 1st run. Then configure database and datashield.
if [ -e /opt/opal/bin/first_run.sh ]
    then
    /opt/opal/bin/first_run.sh
    mv /opt/opal/bin/first_run.sh /opt/opal/bin/first_run.sh.done
fi

tail -f $OPAL_HOME/logs/opal.log