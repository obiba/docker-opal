#!/bin/bash
set -e

if [ "$1" = 'app' ]; then
    if [ "$(id -u)" = 0 ]; then
        chown -R opal "$OPAL_HOME"
        exec gosu opal /opt/opal/bin/start.sh
    fi
    exec /opt/opal/bin/start.sh
fi

exec "$@"
