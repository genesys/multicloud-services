###############################################################################
# Because of using private helm repository in gh-workflow,
# we have to redefine it to certain public repository 
###############################################################################
helm repo add --force-update helm_repo https://charts.bitnami.com/bitnami
helm repo update

###############################################################################
# Post installation Postgres performance benchmark
#   - checking that postgres instance is in working state
#   - cheking the performance
###############################################################################
function pg_benchmark() {
    PGPWD=$(kubectl get secret $RELEASE-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)

    kubectl wait pod --selector "app.kubernetes.io/instance=$RELEASE" --for condition=ready --timeout=300s
    sleep 10 # small pause to be sure that postgres is ready
    
    ## Performace test (transactions per second, latencies, etc)
    print_log "______ Start postgres benchmark _______________"
    SVC="$RELEASE-postgresql"
    kubectl run psql-client -i --rm --restart=Never --image=postgres \
        --env=PGUSER=postgres --env=PGPASSWORD=$PGPWD -- sh -c \
        "pgbench -h $SVC -i pg_bench && pgbench -h $SVC -c 10 -t 1000 -P 2 pg_bench" || true
    
    print_log "_______________________________________________"
}
