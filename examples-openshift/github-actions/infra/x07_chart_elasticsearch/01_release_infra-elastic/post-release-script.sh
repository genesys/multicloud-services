oc adm policy add-scc-to-user privileged -z elastic-data -n $NS
oc adm policy add-scc-to-user privileged -z elastic-master -n $NS
oc adm policy add-scc-to-user privileged -z elastic-coordinating -n $NS