export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"

apk add --update postgresql-client

echo Check iwd-${tenant_sid} database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = 'iwddm-${tenant_sid}'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"iwddm-${tenant_sid}\""

echo Check $iwddm_db_user user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$iwddm_db_user'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -h ${POSTGRES_ADDR} -c "CREATE USER \"$iwddm_db_user\" WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$iwddm_db_password'"
fi
psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"iwddm-${tenant_sid}\" to \"$iwddm_db_user\""

echo Check $gcxi_db_user user
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_user WHERE usename = '$gcxi_db_user'"| grep -q 1
if [ $? -ne 0 ]; then
    psql -h ${POSTGRES_ADDR} -c "CREATE USER \"$gcxi_db_user\" WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$gcxi_db_password'"
fi
psql -h ${POSTGRES_ADDR} -c "GRANT all privileges on database \"iwddm-${tenant_sid}\" to \"$gcxi_db_user\""