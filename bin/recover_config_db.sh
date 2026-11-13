#!/bin/bash
#
# Recover the embedded H2 configuration database of Opal: export it to SQL with H2's Recover tool, load the export
# into a new database file, and put that file in place of the damaged one. The damaged files are moved aside, not
# deleted. The opal user is recreated with its original password, so Opal opens the new file as it did the old one.
#
# Usage: recover_config_db.sh [--force]
#   --force  go on even when parts of the file could not be read (their rows are then missing)
#
set -e

FORCE=false
[ "$1" = "--force" ] && FORCE=true

CONFIG=$OPAL_HOME/data/config
DB=$CONFIG/opal-config.mv.db
H2=$(ls $OPAL_DIST/lib/h2-*.jar 2>/dev/null | head -1)
STAMP=$(date +%Y%m%d-%H%M%S)

fail () {
  echo "ERROR: $1" >&2
  exit 1
}

[ -n "$POSTGRESCONFIG_HOST" ] && fail "the configuration database is on PostgreSQL ($POSTGRESCONFIG_HOST), not embedded: nothing to recover here."
[ -f "$DB" ] || fail "no embedded configuration database at $DB."
[ -n "$H2" ] || fail "no H2 library in $OPAL_DIST/lib."

# H2 holds a lock on the file while the database is open: a lock taken here means no Opal has it open, in this
# container or in another one on the same volume. A lock file left by a crash does not get in the way.
python3 - "$DB" <<'EOF' || fail "$DB is in use: stop Opal before recovering its configuration database."
import fcntl, os, sys
fd = os.open(sys.argv[1], os.O_RDWR)
try:
    fcntl.lockf(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
except OSError:
    sys.exit(1)
EOF

WORK=$OPAL_HOME/work/config-recovery-$STAMP
mkdir -p $WORK/old $WORK/new
cp $DB $WORK/old/

echo "Exporting $DB to SQL..."
java -cp $H2 org.h2.tools.Recover -dir $WORK/old -db opal-config
SQL=$WORK/old/opal-config.h2.sql

ERRORS=$(grep -c "// error" $SQL || true)
if [ "$ERRORS" -gt 0 ]; then
  echo "$ERRORS part(s) of the file could not be read, their rows are missing from the export:"
  grep "// error" $SQL | head -20
  if [ "$FORCE" != true ]; then
    echo "Nothing was changed. The export is in $SQL."
    echo "Run again with --force to recover what could be read."
    exit 1
  fi
fi

echo "Loading the export into a new database..."
PASSWORD=$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')
URL="jdbc:h2:file:$WORK/new/opal-config"
java -cp $H2 org.h2.tools.RunScript -url "$URL" -user recovery -password $PASSWORD -script $SQL
# without the opal user, the export is not one of a database Opal can open: leave everything as it is
java -cp $H2 org.h2.tools.Shell -url "$URL" -user recovery -password $PASSWORD \
  -sql "SELECT USER_NAME FROM INFORMATION_SCHEMA.USERS WHERE USER_NAME = 'OPAL'" | grep -qx "OPAL" || \
  fail "the export has no opal user, too little of the file could be read. Nothing was changed, the export is in $SQL."
# the export recreates the opal user with its original password, the temporary one is not needed any more
java -cp $H2 org.h2.tools.Shell -url "$URL" -user recovery -password $PASSWORD -sql "DROP USER recovery" > /dev/null

DAMAGED=$OPAL_HOME/data/config.damaged-$STAMP
mkdir $DAMAGED
mv $CONFIG/opal-config.* $DAMAGED/
mv $SQL $DAMAGED/
cp $WORK/new/opal-config.mv.db $CONFIG/
rm -rf $WORK

echo "The configuration database has been recovered. The damaged files and the SQL export are in $DAMAGED."
echo "Start Opal and check that the projects, users and permissions are there."
