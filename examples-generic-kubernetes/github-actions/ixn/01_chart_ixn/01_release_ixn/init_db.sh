export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"

apk add --update postgresql-client

echo Check $IXN_DB database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '$IXN_DB'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"$IXN_DB\""

echo Check $IXN_NODE_DB database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '$IXN_NODE_DB'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"$IXN_NODE_DB\""

echo Check $ixn_db_user user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$ixn_db_user'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -h ${POSTGRES_ADDR} -c "CREATE USER \"$ixn_db_user\" WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$ixn_db_password'"
    psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"$IXN_DB\" to \"$ixn_db_user\""
    psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"$IXN_NODE_DB\" to \"$ixn_db_user\""
fi

