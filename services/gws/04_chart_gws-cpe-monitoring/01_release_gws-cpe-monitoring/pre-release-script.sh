# Helm does not allow to create or update resource created outside of this release
# Hence kubectl instead of Helm, to add/update alerts and dashboards
# Note: alerts and dashboards can be already created by service helm charts

# Standard gws-monitoring chart already creates Alerts and Configmaps

#echo "Adding/updating Alerts for $SERVICE"
#kubectl apply -k alerts/

#echo "Adding/updating Configmaps of Grafana dashboards for $SERVICE"
#kubectl apply -k configmaps-dashboards/

print_log "Installing Grafana dashboard CRDs by helm"

[[ "$COMMAND" == "install" ]]  && export PARAMS=" --install"
[[ "$COMMAND" == "validate" ]] && export PARAMS=" --install --dry-run"

# latest helm package
hlmch=$(ls -t deploy-app-dashboards-* | head -n1)
export PARAMS+=" $(pwd)/$hlmch"