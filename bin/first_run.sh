#!/bin/bash

# Configure some databases for IDs and data

# Helper functions

function makeJSONDataDB () {
  sed s/@name@/$1/g /opt/opal/data/tabular-sql-data.json | \
      sed s/@driver@/$2/g | \
      sed s/@driver_class@/$3/g | \
      sed s/@host@/$4/g | \
      sed s/@port@/$5/g | \
      sed s/@db@/$6/g | \
      sed s/@user@/$7/g | \
      sed s/@pwd@/$8/g | \
      sed s/@default_storage@/$9/g
}

function makeJSONIDsDB () {
  sed s/@driver@/$1/g /opt/opal/data/tabular-sql-ids.json | \
      sed s/@driver_class@/$2/g | \
      sed s/@host@/$3/g | \
      sed s/@port@/$4/g | \
      sed s/@db@/$5/g | \
      sed s/@user@/$6/g | \
      sed s/@pwd@/$7/g
}

# Legacy parameters
if [ -n "$MONGO_PORT_27017_TCP_ADDR" ] ; then MONGO_HOST=$MONGO_PORT_27017_TCP_ADDR ; fi
if [ -n "$MONGO_PORT_27017_TCP_PORT" ] ; then MONGO_PORT=$MONGO_PORT_27017_TCP_PORT ; fi
if [ -n "$MYSQLIDS_PORT_3306_TCP_ADDR" ] ; then MYSQLIDS_HOST=$MYSQLIDS_PORT_3306_TCP_ADDR ; fi
if [ -n "$MYSQLIDS_PORT_3306_TCP_PORT" ] ; then MYSQLIDS_PORT=$MYSQLIDS_PORT_3306_TCP_PORT ; fi
if [ -n "$MYSQLDATA_PORT_3306_TCP_ADDR" ] ; then MYSQLDATA_HOST=$MYSQLDATA_PORT_3306_TCP_ADDR ; fi
if [ -n "$MYSQLDATA_PORT_3306_TCP_PORT" ] ; then MYSQLDATA_PORT=$MYSQLDATA_PORT_3306_TCP_PORT ; fi

#
# MongoDB
#

if [ -n "$MONGO_HOST" ]
then
	if [ -z "$MONGO_PORT" ]
	then
		MONGO_PORT=27017
	fi
	MG_USER=""
	if [ -n "$MONGO_USER" ] ; then MG_USER=$MONGO_USER ; fi
	MG_PWD=""
	if [ -n "$MONGO_PASSWORD" ] ; then MG_PWD=$MONGO_PASSWORD ; fi
	MGID_DB="opal_ids"
	if [ -n "$MONGOIDS_DATABASE" ] ; then MGID_DB=$MONGOIDS_DATABASE ; fi
	MGD_DB="opal_data"
	if [ -n "$MONGODATA_DATABASE" ] ; then MGD_DB=$MONGODATA_DATABASE ; fi

	if [ -z "$MYSQLIDS_HOST" ] && [ -z "$MARIADBIDS_HOST" ] && [ -z "$POSTGRESIDS_HOST" ]
		then
		echo "Initializing Opal IDs database with MongoDB..."
		sed s/@host@/$MONGO_HOST/g /opt/opal/data/mongodb-ids.json | \
        sed s/@port@/$MONGO_PORT/g | \
        sed s/@db@/$MGID_DB/g | \
        sed s/@user@/$MG_USER/g | \
        sed s/@pwd@/$MG_PWD/g | \
        opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
	fi
	echo "Initializing Opal data database with MongoDB..."
	sed s/@host@/$MONGO_HOST/g /opt/opal/data/mongodb-data.json | \
      sed s/@port@/$MONGO_PORT/g | \
      sed s/@db@/$MGD_DB/g | \
      sed s/@user@/$MG_USER/g | \
      sed s/@pwd@/$MG_PWD/g | \
      opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

#
# MySQL
#

if [ -n "$MYSQLIDS_HOST" ]
	then
	echo "Initializing Opal IDs database with MySQL..."

	DB_PORT="3306"
	if [ -n "$MYSQLIDS_PORT" ] ; then DB_PORT=$MYSQLIDS_PORT ; fi
	DB_DB="opal"
	if [ -n "$MYSQLIDS_DATABASE" ] ; then DB_DB=$MYSQLIDS_DATABASE ; fi
	DB_USER="root"
	if [ -n "$MYSQLIDS_USER" ] ; then DB_USER=$MYSQLIDS_USER ; fi

	makeJSONIDsDB "mysql" "com.mysql.jdbc.Driver" $MYSQLIDS_HOST $DB_PORT $DB_DB $DB_USER $MYSQLIDS_PASSWORD | \
		opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

if [ -n "$MYSQLDATA_HOST" ]
	then
	echo "Initializing Opal data database with MySQL..."

	DB_PORT="3306"
	DB_DB="opal"
	if [ -n "$MYSQLDATA_DATABASE" ] ; then DB_DB=$MYSQLDATA_DATABASE ; fi
	DB_USER="root"
	if [ -n "$MYSQLDATA_USER" ] ; then DB_USER=$MYSQLDATA_USER ; fi
	DB_DEFAULT="false"
	if [ -z "$MONGO_HOST" ] ; then DB_DEFAULT="true" ; fi

	makeJSONDataDB "mysqldb" "mysql" "com.mysql.jdbc.Driver" $MYSQLDATA_HOST $DB_PORT $DB_DB $DB_USER $MYSQLDATA_PASSWORD $DB_DEFAULT | \
		opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

#
# MariaDB
#

if [ -n "$MARIADBIDS_HOST" ] && [ -z "$MYSQLIDS_HOST" ]
	then
	echo "Initializing Opal IDs database with MariaDB..."

	DB_PORT="3306"
	DB_DB="opal"
	if [ -n "$MARIADBIDS_DATABASE" ] ; then DB_DB=$MARIADBIDS_DATABASE ; fi
	DB_USER="root"
	if [ -n "$MARIADBIDS_USER" ] ; then DB_USER=$MARIADBIDS_USER ; fi

	makeJSONIDsDB "mariadb" "org.mariadb.jdbc.Driver" $MARIADBIDS_HOST $DB_PORT $DB_DB $DB_USER $MARIADBIDS_PASSWORD | \
		opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

if [ -n "$MARIADBDATA_HOST" ]
	then
	echo "Initializing Opal data database with MariaDB..."

	DB_PORT="3306"
	DB_DB="opal"
	if [ -n "$MARIADBDATA_DATABASE" ] ; then DB_DB=$MARIADBDATA_DATABASE ; fi
	DB_USER="root"
	if [ -n "$MARIADBDATA_USER" ] ;	then DB_USER=$MARIADBDATA_USER ; fi
	DB_DEFAULT="false"
	if [ -z "$MONGO_HOST" ] && [ -z "$MYSQLDATA_HOST" ] ; then DB_DEFAULT="true" ; fi

	makeJSONDataDB "mariadb" "mariadb" "org.mariadb.jdbc.Driver" $MARIADBDATA_HOST $DB_PORT $DB_DB $DB_USER $MARIADBDATA_PASSWORD $DB_DEFAULT | \
		opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

#
# PostgreSQL
#

if [ -n "$POSTGRESIDS_HOST" ] && [ -z "$MARIADBIDS_HOST" ] && [ -z "$MYSQLIDS_HOST" ]
	then
	echo "Initializing Opal IDs database with PostgreSQL..."

	DB_PORT="5432"
	DB_DB="opal"
	if [ -n "$POSTGRESIDS_DATABASE" ] ; then DB_DB=$POSTGRESIDS_DATABASE ; fi
	DB_USER="root"
	if [ -n "$POSTGRESIDS_USER" ] ; then DB_USER=$POSTGRESIDS_USER ; fi

	makeJSONIDsDB "postgresql" "org.postgresql.Driver" $POSTGRESIDS_HOST $DB_PORT $DB_DB $DB_USER $POSTGRESIDS_PASSWORD | \
		opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

if [ -n "$POSTGRESDATA_HOST" ]
	then
	echo "Initializing Opal data database with PostgreSQL..."

	DB_PORT="5432"
	DB_DB="opal"
	if [ -n "$POSTGRESDATA_DATABASE" ] ; then DB_DB=$POSTGRESDATA_DATABASE ; fi
	DB_USER="root"
	if [ -n "$POSTGRESDATA_USER" ] ; then DB_USER=$POSTGRESDATA_USER ; fi
	DB_DEFAULT="false"
	if [ -z "$MONGO_HOST" ] && [ -z "$MYSQLDATA_HOST" ] && [ -z "$MARIADBDATA_HOST" ] ; then DB_DEFAULT="true" ; fi

	makeJSONDataDB "postgresdb" "postgresql" "org.postgresql.Driver" $POSTGRESDATA_HOST $DB_PORT $DB_DB $DB_USER $POSTGRESDATA_PASSWORD $DB_DEFAULT | \
		opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

# Configure datashield packages
if [ -n "$ROCK_HOST" ] || [ -n "$RSERVER_HOST" ]
	then
	echo "Initializing Datashield..."
	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /datashield/packages?name=datashield
fi
