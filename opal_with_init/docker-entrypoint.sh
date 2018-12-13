#!/bin/bash
set -e

if [ "$1" = 'app' ]; then
    chown -R opal "$OPAL_HOME"
    exec cdct/opal/bin/start.sh
fi

exec "$@"
