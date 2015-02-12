# Start opal as a service
service opal start

# Wait for the opal server to be up and running
sleep 5

# check if 1st run. Then configure database.
if [ -e /opt/opal/bin/first_run.sh ]
    then
    bash /opt/opal/bin/first_run.sh
    mv /opt/opal/bin/first_run.sh /opt/opal/bin/first_run.sh.done
fi


echo "."

# Tail the log
tail -f /var/log/opal/opal.log