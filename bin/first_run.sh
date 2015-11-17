#!/bin/bash

# Configure some databases for IDs and data
echo "Initializing Opal databases..."
while [ `opal rest -o https://localhost:8443 -u administrator -p password -m GET /system/databases | grep -ch "mongodb"` -eq 0 ]
do
    sleep 5
    sed s/@mongo_host@/$MONGO_PORT_27017_TCP_ADDR/g /opt/opal/data/idsdb.json | \
        sed s/@mongo_port@/$MONGO_PORT_27017_TCP_PORT/g | \
        opal rest -o https://localhost:8443 -u administrator -p password -m POST /system/databases --content-type "application/json"
    sed s/@mongo_host@/$MONGO_PORT_27017_TCP_ADDR/g /opt/opal/data/mongodb.json | \
        sed s/@mongo_port@/$MONGO_PORT_27017_TCP_PORT/g | \
        opal rest -o https://localhost:8443 -u administrator -p password -m POST /system/databases --content-type "application/json"
done