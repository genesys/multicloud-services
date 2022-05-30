export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"

apk add --update postgresql-client

echo Check GES database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"$DB_NAME\""

echo Check $DB_USER user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$DB_USER'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -h ${POSTGRES_ADDR} -c "CREATE USER $DB_USER WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$DB_PASSWORD'"
    psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"$DB_NAME\" to $DB_USER"
fi
echo DB init completed! 