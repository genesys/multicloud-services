# Add prometheus datasource
kubectl apply -f grafana-datasource-prometheus.yaml

# Check pod status
kubectl rollout status deploy grafana-operator --timeout=2m
kubectl rollout status deploy grafana-deployment --timeout=2m

# Check that CRD is added
kubectl get crd grafanadashboards.integreatly.org >/dev/null \
    && print_log "CRD GrafanaDashboards can be used now!" \
    || error_exit "CRD GrafanaDashboards is not installed, please investigate"

print_log "Grafana operator is successfully installed"
print_log "Web UI login: https://grafana.$DOMAIN"
print_log "you can find login credentials in secret \"grafana-admin-credentials\""


##################################################################################
### (Optionally) adding Grafana data source
##################################################################################

# Pointing to prometheus-stack service
prom_url=http://prometheus-operated.${NS}.svc.${DNS_SCOPE}:9090

kubectl apply -f - <<EOF
apiVersion: integreatly.org/v1alpha1
kind: GrafanaDataSource
metadata:
  name: prometheus
spec:
  name: prometheus.yaml
  datasources:
    - access: proxy
      editable: true
      isDefault: true
      jsonData:
        timeInterval: 5s
      name: Prometheus
      type: prometheus
      url: $prom_url
      version: 1
EOF

# For Openshift if using native prometheus stack:
# https://docs.openshift.com/container-platform/4.6/monitoring/enabling-monitoring-for-user-defined-projects.html
# Prometheus will be deployed in namespace openshift-user-workload-monitoring
if [ "$CLUSTER_TYPE" == "openshift" ]
then
    prom_url=https://thanos-querier-openshift-monitoring.$DOMAIN

    auth_secr=$(kubectl get secret -n openshift-user-workload-monitoring \
        | grep -m1 prometheus-user-workload-token | awk '{print $1}')
    
    auth_token=$(get_secret $auth_secr token openshift-user-workload-monitoring)

    kubectl apply -f - <<EOF
    apiVersion: integreatly.org/v1alpha1
    kind: GrafanaDataSource
    metadata:
      name: prometheus-oc
    spec:
      name: prometheus-oc.yaml
      datasources:
        - access: proxy
          editable: true
          isDefault: false
          jsonData:
            httpHeaderName1: Authorization
            timeInterval: 5s
            tlsSkipVerify: true
          secureJsonData:
            httpHeaderValue1: |
              Bearer $auth_token
          name: Prometheus-oc
          type: prometheus
          url: $prom_url
          version: 1
EOF

fi