export PGUSER="${ucsx_master_db_user}"
export PGPASSWORD="${ucsx_master_db_password}"

apk add --update postgresql-client

echo Check ucsx database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME_UCSX}'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"${DB_NAME_UCSX}\""