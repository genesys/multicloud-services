###############################################################################
# Create route instead ingress in OpenShift cluster
###############################################################################
 if ! oc get route | grep wwe | grep edge ; then
      echo "Route does not exist, creating it"
      oc create route edge --service=wwe-wwe-nginx --hostname=wwe.$DOMAIN --port=http
    else
      echo "Edge route already exists"
 fi
