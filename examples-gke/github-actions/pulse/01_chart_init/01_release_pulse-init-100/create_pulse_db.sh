export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"

apk add --update postgresql-client

echo Check pulse database
psql -h ${POSTGRES_ADDR} -tc "SELECT 1 FROM pg_database WHERE datname = 'pulse'"| grep -q 1 || \
    psql -h ${POSTGRES_ADDR} -c "CREATE DATABASE \"pulse\""