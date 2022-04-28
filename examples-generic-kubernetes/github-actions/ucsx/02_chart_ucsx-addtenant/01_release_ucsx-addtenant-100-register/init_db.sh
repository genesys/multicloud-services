export PGUSER="${ucsx_master_db_user}"
export PGPASSWORD="${ucsx_master_db_password}"

apk add --update postgresql-client

echo Check $DB_NAME_UCSX database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME_UCSX'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"$DB_NAME_UCSX\""


psql -h ${POSTGRES_ADDR} -d $DB_NAME_UCSX -c "CREATE EXTENSION IF NOT EXISTS \"pg_prewarm\""
psql -h ${POSTGRES_ADDR} -d $DB_NAME_UCSX -c "CREATE EXTENSION IF NOT EXISTS \"intarray\""
# Alternatively, we can add Superuser permission to user $ucsx_tenant_100_db_user, to create DB extensions, etc
# psql -h ${POSTGRES_ADDR} -c "CREATE USER $ucsx_tenant_100_db_user WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$ucsx_tenant_100_db_password'"


echo Check $ucsx_tenant_db_user user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$ucsx_tenant_db_user'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -h ${POSTGRES_ADDR} -c "CREATE USER $ucsx_tenant_db_user WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$ucsx_tenant_db_password'"
    psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"$DB_NAME_UCSX\" to $ucsx_tenant_db_user"
fi
