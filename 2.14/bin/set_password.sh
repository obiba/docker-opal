#!/bin/bash

adminpw=$(echo -n $OPAL_ADMINISTRATOR_PASSWORD | xargs java -jar /usr/share/opal/tools/lib/obiba-password-hasher-*-cli.jar)
cat $OPAL_HOME/conf/shiro.ini | sed -e "s,^administrator\s*=.*\,,administrator=$adminpw\,," > /tmp/shiro.ini && \
    mv /tmp/shiro.ini $OPAL_HOME/conf/shiro.ini