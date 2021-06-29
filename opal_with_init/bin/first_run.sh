#!/bin/bash

# Configure some databases for IDs and data
if [ -n "$MONGO_PORT_27017_TCP_ADDR" ]
	then
	echo "Initializing Opal databases with MongoDB..."
	if [ -z "$MYSQLIDS_PORT_3306_TCP_ADDR" ]
		then
		sed s/@mongo_host@/$MONGO_PORT_27017_TCP_ADDR/g /opt/opal/data/mongodb-ids.json | \
    		sed s/@mongo_port@/$MONGO_PORT_27017_TCP_PORT/g | \
    		opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
    fi
	sed s/@mongo_host@/$MONGO_PORT_27017_TCP_ADDR/g /opt/opal/data/mongodb-data.json | \
    	sed s/@mongo_port@/$MONGO_PORT_27017_TCP_PORT/g | \
    	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
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
    	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
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
    	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/databases --content-type "application/json"
fi

# Configure datashield packages
if [ -n "$RSERVER_PORT_6312_TCP_ADDR" ]
	then
	echo "Initializing Datashield..."
	opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /datashield/packages?name=datashield
fi

# Configure standard Mongo Db Connection
if [ -n "$MONGODBHOST" ]
	then
	echo "initialising mongo db with ids and data"
	echo "{\"name\": \"_identifiers\", \"defaultStorage\":false, \"usage\": \"STORAGE\", \"usedForIdentifiers\":true, \"mongoDbSettings\" : {\"url\":\"mongodb://$MONGODBHOST:27017/opal_ids\"}}" | opal rest --opal https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --content-type 'application/json' -m POST /system/databases 
	echo "{\"name\":\"test\",\"defaultStorage\":false, \"usage\": \"STORAGE\", \"mongoDbSettings\" : {\"url\":\"mongodb://$MONGODBHOST:27017/opal_data\"}}" | opal rest --opal https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --content-type 'application/json' -m POST /system/databases
fi

if [ "$INITTESTDATA" == "true" ]
	then

	echo "create a test project..."
	echo '{"name":"test","title":"test", "database": "test"}' | opal rest --opal https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --content-type 'application/json' -m POST /projects

	echo "upload the needed test files files..."
	opal file --opal https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -up /testdata/LifeLines.sav /projects
	opal file --opal https://localhost:8443 -u administrator -p password -up /testdata/CNSIM/CNSIM.zip /projects
	opal file --opal https://localhost:8443 -u administrator -p password -up /testdata/DASIM/DASIM.zip /projects

	echo "import the needed spss files to the test project..."
	opal import-plugin --opal https://localhost:8443 -u  administrator -p  $OPAL_ADMINISTRATOR_PASSWORD --name opal-datasource-spss --config '/testdata/config_test.json' --destination test

	echo "import the CNSIM and DASIM test files to the test project..."
	opal import-xml --opal https://localhost:8443 --user administrator --password password --path /projects/CNSIM.zip --destination test
	opal import-xml --opal https://localhost:8443 --user administrator --password password --path /projects/DASIM.zip --destination test

	echo "create a test user..."
	opal user --opal https://localhost:8443 --user  administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --add --name test --upassword test123
	sleep 10

	echo "give test user permission to access lifeLines table"
	opal perm-table --opal https://localhost:8443 --user  administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --type USER --project test --subject test  --permission view --add --tables LifeLines

	echo "give test user permission to use datashield"
	opal perm-datashield --opal https://localhost:8443 --user  administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --type USER --subject test --permission use --add

	echo "nstall datashield packages"
	opal rest --opal https://localhost:8443 --user  administrator --password  $OPAL_ADMINISTRATOR_PASSWORD -m POST '/datashield/packages?name=datashield'
fi



