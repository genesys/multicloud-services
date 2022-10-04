export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGHOST="${POSTGRES_ADDR}"

apk add --update postgresql-client

echo Check $gws_pg_dbname database
psql -tc "SELECT 1 FROM pg_database WHERE datname = '$gws_pg_dbname'"| grep -q 1 || \
    psql -c "CREATE DATABASE \"$gws_pg_dbname\""

echo Check $gws_pg_dbname_prov database
psql -tc "SELECT 1 FROM pg_database WHERE datname = '$gws_pg_dbname_prov'"| grep -q 1 || \
    psql -c "CREATE DATABASE \"$gws_pg_dbname_prov\""

echo Check $gws_pg_user user
psql -tc "SELECT 1 FROM pg_user WHERE usename = '$gws_pg_user'"| grep -q 1
if [ $? -ne 0 ]; then
    # !!! GWS needs Superuser permission, to create DB extensions, etc !!!
    psql -c "CREATE USER $gws_pg_user WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$gws_pg_pass'"
fi
psql -c "GRANT all privileges on database \"$gws_pg_dbname\" to $gws_pg_user"

echo Check $gws_as_pg_user user
psql -tc "SELECT 1 FROM pg_user WHERE usename = '$gws_as_pg_user'"| grep -q 1
if [ $? -ne 0 ]; then
    # !!! GWS needs Superuser permission, to create DB extensions, etc !!!
    psql -c "CREATE USER $gws_as_pg_user WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$gws_as_pg_pass'"
fi
psql -c "GRANT all privileges on database \"$gws_pg_dbname_prov\" to $gws_as_pg_user"
