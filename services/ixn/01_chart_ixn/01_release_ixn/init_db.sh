export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGHOST="$POSTGRES_ADDR"

apk add --update postgresql-client

echo Check $ixn_db_name database
psql -tc "SELECT 1 FROM pg_database WHERE datname = '$ixn_db_name'"| grep -q 1 || \
    psql -c "CREATE DATABASE \"$ixn_db_name\""

echo Check $ixn_node_db_name database
psql -tc "SELECT 1 FROM pg_database WHERE datname = '$ixn_node_db_name'"| grep -q 1 || \
    psql -c "CREATE DATABASE \"$ixn_node_db_name\""

echo Check $ixn_db_user user
psql -tc "SELECT 1 FROM pg_user WHERE usename = '$ixn_db_user'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -c "CREATE USER \"$ixn_db_user\" WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$ixn_db_password'"
    psql -c "GRANT all privileges on database \"$ixn_db_name\" to \"$ixn_db_user\""
    psql -c "GRANT all privileges on database \"$ixn_node_db_name\" to \"$ixn_db_user\""
fi

