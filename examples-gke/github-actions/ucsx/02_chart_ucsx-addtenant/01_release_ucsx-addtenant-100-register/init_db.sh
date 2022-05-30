export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"

apk add --update postgresql-client

echo Check $ucsx_tenant_db_name database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '$ucsx_tenant_db_name'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"$ucsx_tenant_db_name\""


psql -h ${POSTGRES_ADDR} -d $ucsx_tenant_db_name -c "CREATE EXTENSION IF NOT EXISTS \"pg_prewarm\""
psql -h ${POSTGRES_ADDR} -d $ucsx_tenant_db_name -c "CREATE EXTENSION IF NOT EXISTS \"intarray\""
# Alternatively, we can add Superuser permission to user $ucsx_tenant_100_db_user, to create DB extensions, etc
# psql -h ${POSTGRES_ADDR} -c "CREATE USER $ucsx_tenant_100_db_user WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$ucsx_tenant_100_db_password'"


echo Check $ucsx_tenant_db_user user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$ucsx_tenant_db_user'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -h ${POSTGRES_ADDR} -c "CREATE USER $ucsx_tenant_db_user WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$ucsx_tenant_db_password'"
    psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"$ucsx_tenant_db_name\" to $ucsx_tenant_db_user"
fi
