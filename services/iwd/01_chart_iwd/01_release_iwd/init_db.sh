export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGHOST="$POSTGRES_ADDR"

apk add --update postgresql-client

echo Check ${iwd_db_name} database
psql -tc "SELECT 1 FROM pg_database WHERE datname = '${iwd_db_name}'"| grep -q 1 || \
    psql -c "CREATE DATABASE \"${iwd_db_name}\""

echo Check $iwd_db_user user
psql -tc "SELECT 1 FROM pg_user WHERE usename = '${iwd_db_user}'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -c "CREATE USER \"${iwd_db_user}\" WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '${iwd_db_password}'"
    psql -c "GRANT all privileges on database \"${iwd_db_name}\" to \"${iwd_db_user}\""
fi