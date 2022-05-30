export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"

apk add --update postgresql-client

echo Check $DB_NAME_GWS database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME_GWS'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"$DB_NAME_GWS\""

echo Check $DB_NAME_PROV database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME_PROV'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"$DB_NAME_PROV\""

echo Check $gws_pg_user user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$gws_pg_user'"| grep -q 1
if [ $? -ne 0 ]; then
    # !!! GWS needs Superuser permission, to create DB extensions, etc !!!
    psql -h ${POSTGRES_ADDR} -c "CREATE USER $gws_pg_user WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$gws_pg_pass'"
fi
psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"$DB_NAME_GWS\" to $gws_pg_user"

echo Check $gws_as_pg_user user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$gws_as_pg_user'"| grep -q 1
if [ $? -ne 0 ]; then
    # !!! GWS needs Superuser permission, to create DB extensions, etc !!!
    psql -h ${POSTGRES_ADDR} -c "CREATE USER $gws_as_pg_user WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$gws_as_pg_pass'"
fi
psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"$DB_NAME_PROV\" to $gws_as_pg_user"
