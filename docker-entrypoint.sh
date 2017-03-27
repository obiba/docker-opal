#!/bin/bash
set -e

if [ "$1" = 'app' ]; then
    chown -R opal "$OPAL_HOME"
	unzip -o jennite-vcf-store-$VCF_STORE_VERSION-dist.zip -d $OPAL_HOME/plugins/
    exec gosu opal /opt/opal/bin/start.sh
fi

exec "$@"
