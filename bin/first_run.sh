#!/bin/bash

# Configure some databases for IDs and data

# Legacy parameters
if [ -n "$MONGO_PORT_27017_TCP_ADDR" ]
then
	MONGO_HOST=$MONGO_PORT_27017_TCP_ADDR
fi
if [ -n "$MONGO_PORT_27017_TCP_PORT" ]
then
        MONGO_PORT=$MONGO_PORT_27017_TCP_PORT
fi
if [ -n "$MYSQLIDS_PORT_3306_TCP_ADDR" ]
then
        MYSQLIDS_HOST=$MYSQLIDS_PORT_3306_TCP_ADDR
fi
if [ -n "$MYSQLIDS_PORT_3306_TCP_PORT" ]
then
        MYSQLIDS_PORT=$MYSQLIDS_PORT_3306_TCP_PORT
fi
if [ -n "$MYSQLDATA_PORT_3306_TCP_ADDR" ]
then
        MYSQLDATA_HOST=$MYSQLDATA_PORT_3306_TCP_ADDR
fi
if [ -n "$MYSQLDATA_PORT_3306_TCP_PORT" ]
then
        MYSQLDATA_PORT=$MYSQLDATA_PORT_3306_TCP_PORT
fi

#
# MongoDB
#

if [ -n "$MONGO_HOST" ]
then
	if [ -z "$MONGO_PORT" ]
	then
		MONGO_PORT=27017
	fi
	if [ -z "$MYSQLIDS_HOST" ]
		then
		echo "Initializing Opal IDs database with MongoDB..."
		sed s/@mongo_host@/$MONGO_HOST/g /opt/opal/data/mongodb-ids.json | \
    		sed s/@mongo_port@/$MONGO_PORT/g | \
    		opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
	fi
	echo "Initializing Opal data database with MongoDB..."
	sed s/@mongo_host@/$MONGO_HOST/g /opt/opal/data/mongodb-data.json | \
    	sed s/@mongo_port@/$MONGO_PORT/g | \
    	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

#
# MySQL (TODO MariaDB support)
#

if [ -n "$MYSQLIDS_HOST" ]
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

	sed s/@mysql_host@/$MYSQLIDS_HOST/g /opt/opal/data/mysqldb-ids.json | \
    	sed s/@mysql_port@/$MYSQLIDS_PORT/g | \
    	sed s/@mysql_db@/$MID_DB/g | \
    	sed s/@mysql_user@/$MID_USER/g | \
    	sed s/@mysql_pwd@/$MYSQLIDS_PASSWORD/g | \
    	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

if [ -n "$MYSQLDATA_HOST" ]
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
	if [ -z "$MONGO_HOST" ]
		then
		MD_DEFAULT="true"
	fi

	sed s/@mysql_host@/$MYSQLDATA_HOST/g /opt/opal/data/mysqldb-data.json | \
    	sed s/@mysql_port@/$MYSQLDATA_PORT/g | \
    	sed s/@mysql_db@/$MD_DB/g | \
    	sed s/@mysql_user@/$MD_USER/g | \
    	sed s/@mysql_pwd@/$MYSQLDATA_PASSWORD/g | \
    	sed s/@mysql_default@/$MD_DEFAULT/g | \
    	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

# Configure datashield packages
if [ -n "$RSERVER_HOST" ]
	then
	echo "Initializing Datashield..."
	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /datashield/packages?name=datashield
fi

