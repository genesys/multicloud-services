export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"

apk add --update postgresql-client

echo Check gauth database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"${DB_NAME}\""

echo Check $gauth_pg_username user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$gauth_pg_username'"| grep -q 1
if [ $? -ne 0 ]; then
    #psql -h ${POSTGRES_ADDR} -c "CREATE USER $gauth_pg_username WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$gauth_pg_password'"
    # !!! Gauth needs Superuser permission, to create DB extensions, etc !!!
    psql -h ${POSTGRES_ADDR} -c "CREATE USER $gauth_pg_username WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$gauth_pg_password'"
fi
psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"${DB_NAME}\" to $gauth_pg_username"