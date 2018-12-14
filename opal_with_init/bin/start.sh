#!/bin/bash

# Make sure conf folder is available
if [ ! -d $OPAL_HOME/conf ]
    then
    mkdir -p $OPAL_HOME/conf
    cp -r /usr/share/opal/conf/* $OPAL_HOME/conf
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

if [ -e /opt/opal/bin/set_password.sh ]
    then
    /opt/opal/bin/set_password.sh
    mv /opt/opal/bin/set_password.sh /opt/opal/bin/set_password.sh.done
fi

# Start opal
if [ -e /opt/opal/bin/first_run.sh ]
    then
    # check if 1st run. Then configure database and datashield.
	/usr/share/opal/bin/opal &

	# Wait for the opal server to be up and running
	echo "startup opal and install spss import pluging..."
	until opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m GET /system/databases &> /dev/null
	do
	    sleep 5
	done

    # install spss plugin
    echo '' | opal rest --opal https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --content-type 'application/json' -m POST '/plugins?name=opal-datasource-spss&version=1.0.1'


    echo "Restarting Opal and waiting for it to be ready..."
    kill `pgrep -f bin/opal`
    kill `pgrep -f opal/lib`
    /usr/share/opal/bin/opal &

	until opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m GET /system/databases &> /dev/null
	do
	    sleep 5
	done

    /opt/opal/bin/first_run.sh
    mv /opt/opal/bin/first_run.sh /opt/opal/bin/first_run.sh.don

    tail -f $OPAL_HOME/logs/opal.log

else
	/usr/share/opal/bin/opal
fi
