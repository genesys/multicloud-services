# For Openshift clusters only

echo "Adding necessary rights to fluent-bit SA"
oc adm policy add-scc-to-user node-exporter -z fluent-bit