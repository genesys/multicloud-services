###############################################################################
# https://all.docs.genesys.com/BDS/Current/BDSPEGuide/Configure#Configs_Layout
###############################################################################

# Updating production date in configmap like bds-config-t100-100

yesterday=$(date -v-2d +"%Y"-"%m"-"%d") #(date -d "2 days ago" '+%Y-%m-%d')

cfg_name=config-t${TENANT_SID}-${TENANT_SID}

kubectl get cm bds-$cfg_name -o jsonpath={.data} | jq -r --arg v1 "$cfg_name.json" '.[$v1]' | \
 	jq --arg yesterday "$yesterday" \
	'.tenants.MultiRegionExampleTenant.production_date = $yesterday' > tmpatched

JS=$(kubectl create cm tmp-cm --dry-run=client --from-file=$cfg_name.json=tmpatched -o jsonpath='{.data}')

kubectl patch cm bds-$cfg_name -p "{\"data\":$JS}"