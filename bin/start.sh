service opal start

sleep 30

echo "{\"usedForIdentifiers\": true, \"name\": \"_identifiers\", \"usage\": \"STORAGE\", \"defaultStorage\": false, \"mongoDbSettings\": { \"url\": \"mongodb://$MONGODB_PORT_27017_TCP_ADDR:$MONGODB_PORT_27017_TCP_PORT/opal_ids\", \"username\": \"\", \"password\": \"\", \"properties\": \"\" }}" | opal rest -o https://localhost:8443 -u administrator -p password -m POST /system/databases --content-type "application/json"
echo "{\"usedForIdentifiers\": false, \"name\": \"mongodb\", \"usage\": \"STORAGE\", \"defaultStorage\": true, \"mongoDbSettings\": { \"url\": \"mongodb://$MONGODB_PORT_27017_TCP_ADDR:$MONGODB_PORT_27017_TCP_PORT/opal_data\", \"username\": \"\", \"password\": \"\",  \"properties\": \"\" }}" | opal rest -o https://localhost:8443 -u administrator -p password -m POST /system/databases --content-type "application/json"

tail -f /var/log/opal/opal.log