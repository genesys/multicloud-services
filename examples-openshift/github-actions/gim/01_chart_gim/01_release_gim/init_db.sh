export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"

apk add --update postgresql-client

echo Check GIM database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '$gim_pgdb_etl_name'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"$gim_pgdb_etl_name\""

echo Check $gim_pgdb_etl_user user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$gim_pgdb_etl_user'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -h ${POSTGRES_ADDR} -c "CREATE USER $gim_pgdb_etl_user WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$gim_pgdb_etl_password'"
    psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"$gim_pgdb_etl_name\" to $gim_pgdb_etl_user"
fi
