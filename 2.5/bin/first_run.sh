#!/bin/bash

# Configure some databases for IDs and data
if [ -n "$MONGO_PORT_27017_TCP_ADDR" ]
	then
	echo "Initializing Opal databases..."
	sed s/@mongo_host@/$MONGO_PORT_27017_TCP_ADDR/g /opt/opal/data/idsdb.json | \
    	sed s/@mongo_port@/$MONGO_PORT_27017_TCP_PORT/g | \
    	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
	sed s/@mongo_host@/$MONGO_PORT_27017_TCP_ADDR/g /opt/opal/data/mongodb.json | \
    	sed s/@mongo_port@/$MONGO_PORT_27017_TCP_PORT/g | \
    	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

# Configure datashield packages
if [ -n "$RSERVER_PORT_6312_TCP_ADDR" ]
	then
	echo "Initializing Datashield..."
	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /datashield/packages?name=datashield
fi