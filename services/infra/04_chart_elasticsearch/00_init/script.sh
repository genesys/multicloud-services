###############################################################################
# Redefine helm_repo
###############################################################################
helm repo add --force-update helm_repo https://charts.bitnami.com/bitnami
helm repo update
helm search repo helm_repo/elasticsearch --version=$CHART_VER
