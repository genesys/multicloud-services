###############################################################################
# Validate that all pods have status running
###############################################################################
( ! wait_running_status "service=cxc" 600 cxc-provisioning ) && exit 1

echo "Post-realease actions are done!"