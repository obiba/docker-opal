#!/bin/bash

curl -X POST -k -H "Accept:application/x-protobuf+json" https://localhost:8443/ws/auth/sessions -d "username=administrator" -d "password=$OPAL_ADMINISTRATOR_PASSWORD" --cookie-jar /tmp/.cookie-jar

# Configure some databases for IDs and data
if [ -n "$MONGO_PORT_27017_TCP_ADDR" ]
	then
	echo "Initializing Opal databases with MongoDB..."
	if [ -z "$MYSQLIDS_PORT_3306_TCP_ADDR" ]
		then
		sed s/@mongo_host@/$MONGO_PORT_27017_TCP_ADDR/g /opt/opal/data/mongodb-ids.json | \
    		sed s/@mongo_port@/$MONGO_PORT_27017_TCP_PORT/g | \
    		curl -X POST -k -H "Accept:application/x-protobuf+json" -H "Content-Type:application/json" https://localhost:8443/ws/system/databases --cookie /tmp/.cookie-jar -d @-
    fi
	sed s/@mongo_host@/$MONGO_PORT_27017_TCP_ADDR/g /opt/opal/data/mongodb-data.json | \
    	sed s/@mongo_port@/$MONGO_PORT_27017_TCP_PORT/g | \
    	curl -X POST -k -H "Accept:application/x-protobuf+json" -H "Content-Type:application/json" https://localhost:8443/ws/system/databases --cookie /tmp/.cookie-jar -d @-
fi

if [ -n "$MYSQLIDS_PORT_3306_TCP_ADDR" ]
	then
	echo "Initializing Opal IDs database with MySQL..."

	MID_DB="opal"
	if [ -n "$MYSQLIDS_DATABASE" ]
		then
		MID_DB=$MYSQLIDS_DATABASE
	fi

	MID_USER="root"
	if [ -n "$MYSQLIDS_USER" ]
		then
		MID_USER=$MYSQLIDS_USER
	fi

	sed s/@mysql_host@/$MYSQLIDS_PORT_3306_TCP_ADDR/g /opt/opal/data/mysqldb-ids.json | \
    	sed s/@mysql_port@/$MYSQLIDS_PORT_3306_TCP_PORT/g | \
    	sed s/@mysql_db@/$MID_DB/g | \
    	sed s/@mysql_user@/$MID_USER/g | \
    	sed s/@mysql_pwd@/$MYSQLIDS_PASSWORD/g | \
    	curl -X POST -k -H "Accept:application/x-protobuf+json" -H "Content-Type:application/json" https://localhost:8443/ws/system/databases --cookie /tmp/.cookie-jar -d @-
fi

if [ -n "$MYSQLDATA_PORT_3306_TCP_ADDR" ]
	then
	echo "Initializing Opal data database with MySQL..."

	MD_DB="opal"
	if [ -n "$MYSQLDATA_DATABASE" ]
		then
		MD_DB=$MYSQLDATA_DATABASE
	fi

	MD_USER="root"
	if [ -n "$MYSQLDATA_USER" ]
		then
		MD_USER=$MYSQLDATA_USER
	fi

	MD_DEFAULT="false"
	if [ -z "$MONGO_PORT_27017_TCP_ADDR" ]
		then
		MD_DEFAULT="true"
	fi

	sed s/@mysql_host@/$MYSQLDATA_PORT_3306_TCP_ADDR/g /opt/opal/data/mysqldb-data.json | \
    	sed s/@mysql_port@/$MYSQLDATA_PORT_3306_TCP_PORT/g | \
    	sed s/@mysql_db@/$MD_DB/g | \
    	sed s/@mysql_user@/$MD_USER/g | \
    	sed s/@mysql_pwd@/$MYSQLDATA_PASSWORD/g | \
    	sed s/@mysql_default@/$MD_DEFAULT/g | \
    	curl -X POST -k -H "Accept:application/x-protobuf+json" -H "Content-Type:application/json" https://localhost:8443/ws/system/databases --cookie /tmp/.cookie-jar -d @-
fi

# Configure datashield packages
if [ -n "$RSERVER_PORT_6312_TCP_ADDR" ]
	then
	echo "Initializing Datashield..."
	curl -X POST -k -H "Accept:application/x-protobuf+json" -H "Content-Type:application/json" https://localhost:8443/ws/system/databases --cookie /tmp/.cookie-jar -d @-
fi