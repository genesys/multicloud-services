export PGUSER="$POSTGRES_USER"
export PGPASSWORD="$POSTGRES_PASSWORD"
export PGHOST="$POSTGRES_ADDR"

apk add --update postgresql-client

echo Check gauth database
psql -tc "SELECT 1 FROM pg_database WHERE datname = '${gauth_pg_dbname}'"| grep -q 1 || \
    psql -c "CREATE DATABASE \"${gauth_pg_dbname}\""

echo Check $gauth_pg_username user
psql -tc "SELECT 1 FROM pg_user WHERE usename = '$gauth_pg_username'"| grep -q 1
if [ $? -ne 0 ]; then
    #psql -c "CREATE USER $gauth_pg_username WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$gauth_pg_password'"
    # !!! Gauth needs Superuser permission, to create DB extensions, etc !!!
    psql -c "CREATE USER $gauth_pg_username WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$gauth_pg_password'"
fi
psql -c "GRANT all privileges on database \"${gauth_pg_dbname}\" to $gauth_pg_username"