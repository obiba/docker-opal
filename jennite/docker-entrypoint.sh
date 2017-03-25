#!/bin/bash
set -e

if [ "$1" = 'app' ]; then
	unzip -o jennite-vcf-store-0.1-SNAPSHOT-dist.zip -d $OPAL_HOME/plugins/
    chown -R opal "$OPAL_HOME"

    exec gosu opal /opt/opal/bin/start.sh
fi

exec "$@"
