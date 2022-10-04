###############################################################################
## CXC requires tenant's database to have "tablefunc" extension - add it if not present
db_name=t${TENANT_SID}
echo "ADDING tablefunc EXTENSION to tenant_db $db_name"
kubectl run  --attach db-configurator-$db_name --image=postgres --env=PGUSER=${POSTGRES_USER} \
        --env=PGPASSWORD=${POSTGRES_PASSWORD} --restart='Never' --command -- sh -c \
        "psql -h $POSTGRES_ADDR -d $db_name -tc \"CREATE EXTENSION IF NOT EXISTS tablefunc;\" || echo DB NOT FOUND"
kubectl delete pod db-configurator-$db_name || true
