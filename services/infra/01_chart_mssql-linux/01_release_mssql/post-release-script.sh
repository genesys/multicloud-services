# Post-deployment steps

print_log "Waiting for mssql readiness"

kubectl rollout status deployment mssql-mssql-linux --timeout=5m

print_log "MSSQL is ready"