# Start opal as a service
service opal start

# Wait for the opal server to be up and running
sleep 5

# Configure some databases for IDs and data
echo "Initializing Opal databases..."
while [ `opal rest -o https://localhost:8443 -u administrator -p password -m GET /system/databases | grep -ch "mongodb"` -eq 0 ]
do
	echo -n "."
	sleep 5
	sed s/@mongo_host@/$MONGODB_PORT_27017_TCP_ADDR/g /opt/opal/data/idsdb.json | \
		sed s/@mongo_port@/$MONGODB_PORT_27017_TCP_PORT/g | \
  		opal rest -o https://localhost:8443 -u administrator -p password -m POST /system/databases --content-type "application/json"
	sed s/@mongo_host@/$MONGODB_PORT_27017_TCP_ADDR/g /opt/opal/data/mongodb.json | \
  		sed s/@mongo_port@/$MONGODB_PORT_27017_TCP_PORT/g | \
  		opal rest -o https://localhost:8443 -u administrator -p password -m POST /system/databases --content-type "application/json"
done
echo "."

# Tail the log
tail -f /var/log/opal/opal.log