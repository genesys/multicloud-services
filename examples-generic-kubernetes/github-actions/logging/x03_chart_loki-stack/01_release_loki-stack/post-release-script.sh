# For Openshift clusters only

#	echo "Adding necessary rights to loki and promtail SA"
#	oc adm policy add-scc-to-user anyuid -z loki
#	oc adm policy add-scc-to-user node-exporter -z loki-promtail
#	kubectl patch daemonsets.apps loki-promtail -p \
#		'{"spec":{"template":{"spec":{"containers":[{"name": "promtail","securityContext":{"allowPrivilegeEscalation": true}}]}}}}'
