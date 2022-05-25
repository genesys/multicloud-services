###############################################################################
# Post installation performance benchmarking
#   - checking that postgres instance is in working state
#   - cheking the performance
###############################################################################
pg=$(pwd | sed 's/.*\///' | sed 's/[0-9][0-9]_release_//' | sed 's/\///') 
POSTGRES_PASSWORD=$(kubectl get secret $pg-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)

## Performace test (transactions per second, latencies, etc)
kubectl wait pod --selector "app.kubernetes.io/instance=$pg" --for condition=ready --timeout=300s
sleep 10 # small pause to be sure that postgres is ready
echo "______Starting postgres benchmarking_______________"
SVC="$pg-postgresql"
kubectl run psql-client -i --rm --restart=Never --image=postgres \
    --env=PGUSER=postgres --env=PGPASSWORD=$POSTGRES_PASSWORD -- sh -c \
    "pgbench -h $SVC -i pg_bench && pgbench -h $SVC -c 10 -t 1000 -P 2 pg_bench" || true
echo "________________________________________________________"