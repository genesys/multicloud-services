###############################################################################
# https://all.docs.genesys.com/BDS/Current/BDSPEGuide/Configure#Configs_Layout
###############################################################################

yesterday=$(date -d "2 days ago" '+%Y-%m-%d')

FLN=config-t100-100.json

# Patching production date
cat $FLN | jq --arg yesterday "$yesterday" \
	'.tenants.MultiRegionExampleTenant.production_date = $yesterday' > $FLN.patched

# Creating config map in dry run mode for preparing patching string being properly formatted
JS=$(kubectl create cm tmp-cm --dry-run=client --from-file=$FLN=$FLN.patched -o jsonpath='{.data}')

kubectl patch cm bds-config -p "{\"data\":$JS}"
