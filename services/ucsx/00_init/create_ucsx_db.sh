export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGHOST="${POSTGRES_ADDR}"

apk add --update postgresql-client

echo Check ucsx database
psql -tc "SELECT 1 FROM pg_database WHERE datname = '${ucsx_db_name}'"| grep -q 1 || \
    psql -c "CREATE DATABASE \"${ucsx_db_name}\""