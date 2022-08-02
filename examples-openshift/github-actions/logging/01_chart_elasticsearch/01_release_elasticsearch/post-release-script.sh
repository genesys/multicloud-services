# For Openshift clusters only

echo "Adding necessary rights to elasticsearch SA"
oc adm policy add-scc-to-user anyuid -z elasticsearch