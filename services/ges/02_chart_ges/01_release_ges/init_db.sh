export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGHOST="${POSTGRES_ADDR}"

apk add --update postgresql-client

echo Check GES database
psql -tc "SELECT 1 FROM pg_database WHERE datname = '$ges_db_name'"| grep -q 1 || \
    psql -c "CREATE DATABASE \"$ges_db_name\""

echo Check $ges_db_user user
psql -tc "SELECT 1 FROM pg_user WHERE usename = '$ges_db_user'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -c "CREATE USER $ges_db_user WITH SUPERUSER LOGIN CONNECTION LIMIT -1 PASSWORD '$ges_db_password'"
    psql -c "GRANT all privileges on database \"$ges_db_name\" to $ges_db_user"
fi
echo DB init completed! 