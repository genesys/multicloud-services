export PGUSER=$POSTGRES_USER
export PGPASSWORD=$POSTGRES_PASSWORD


apk add --update postgresql-client

echo Check $tenant_X_pg_db_name database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '$tenant_t100_pg_db_name'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"$tenant_t100_pg_db_name\""

echo Check $tenant_t100_pg_db_user user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$tenant_t100_pg_db_user'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -h ${POSTGRES_ADDR} -c "CREATE USER $tenant_t100_pg_db_user WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$tenant_t100_pg_db_password'"
    psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"$tenant_t100_pg_db_name\" to $tenant_t100_pg_db_user"
fi
