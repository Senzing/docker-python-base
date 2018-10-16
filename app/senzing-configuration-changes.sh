#!/usr/bin/env bash
# Make changes to files based on Environment Variables.

VERSION=1.0.0

# Return codes

OK=0
NOT_OK=1

# Short-circuit for certain parameters

if [ "$1" == "--version" ]; then
  echo "senzing-configuration-changes.sh version ${VERSION}"
  exit ${OK}
fi

# Make modifications based on SENZING_DATABASE_URL value.

if [ -z "${SENZING_DATABASE_URL}" ]; then
  echo "Using internal database"
else

  # Parse the SENZING_DATABASE_URL

  PROTOCOL="$(echo ${SENZING_DATABASE_URL} | sed -e's,^\(.*://\).*,\1,g')"
  DRIVER="$(echo ${SENZING_DATABASE_URL} | cut -d ':' -f1)"
  UPPERCASE_DRIVER=$(echo "${DRIVER}" | tr '[:lower:]' '[:upper:]')
  USERNAME="$(echo ${SENZING_DATABASE_URL} | cut -d '/' -f3 | cut -d ':' -f1)"
  PASSWORD="$(echo ${SENZING_DATABASE_URL} | cut -d ':' -f3 | cut -d '@' -f1)"
  HOST="$(echo ${SENZING_DATABASE_URL} | cut -d '@' -f2 | cut -d ':' -f1)"
  PORT="$(echo ${SENZING_DATABASE_URL} | cut -d ':' -f4 | cut -d '/' -f1)"
  SCHEMA="$(echo ${SENZING_DATABASE_URL} | cut -d '=' -f2)"

  # Modify files

  sed -i.$(date +%s) \
    -e "s|G2Connection=sqlite3://na:na@/opt/senzing/g2/sqldb/G2C.db|G2Connection=${SENZING_DATABASE_URL}|" \
    /opt/senzing/g2/python/G2Project.ini

  sed -i.$(date +%s) \
    -e "s|CONNECTION=sqlite3://na:na@/opt/senzing/g2/sqldb/G2C.db|CONNECTION=${SENZING_DATABASE_URL}|" \
    /opt/senzing/g2/python/G2Module.ini

  echo "" >> /etc/odbc.ini
  sed -i.$(date +%s) \
    -e "\$a[${SCHEMA}]\nDriver = ${UPPERCASE_DRIVER}\nDatabase = ${SCHEMA}\nServer = ${HOST}\nPort = ${PORT}\n" \
    /etc/odbc.ini
fi

# Work-around https://senzing.zendesk.com/hc/en-us/articles/360009212393-MySQL-V8-0-ODBC-client-alongside-V5-x-Server

if [ ! -f /opt/senzing/g2/lib/libmysqlclient.so.21 ]; then
  cp /usr/lib64/mysql/libmysqlclient.so.21 /opt/senzing/g2/lib
fi

# Run the command specified by the parameters

$@
