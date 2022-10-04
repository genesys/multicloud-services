# once tenant is deployed
# it will trigger adding GAuth environment and contact-center
# then we can add CORS settings

kubectl rollout status sts t${TENANT_SID}

sleep 10

gauth_update_cors