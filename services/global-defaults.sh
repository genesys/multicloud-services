#!/usr/bin/env bash

##################################################################
# Global variables
# Default values, that we recommend to adjust for your environment
# via global deployment secrets.

##################################################################
##### ❗ Do not keep any sensitive input here in repository ######
##################################################################

export DEBUG_HELM="false"              # global debug, see deployment.sh
#export DEBUG_CXC="true"               # per-service debug

export LOCATION=westus2                # important attribute for many services
export CONSUL_DC_LOCATION=westus2

# Standard example tenant
export TENANT_SID="100"
export TENANT_UUID="9350e2fc-a1dd-4c65-8d40-1f75a2e080dd"
export SIP_DOMAIN="t${TENANT_SID}.dev.genazure.com"

export DOMAIN=apps.example.com                 #external resolution, for ingresses
export DNS_SCOPE=cluster.local                  #internal resolution, important to adjust for GKE with VPC scope


#######################
### Shared services ###
#######################

export CONSUL_ADDR=consul-server.infra.svc.${DNS_SCOPE}       # must use FQDN for headless services
#export CONSUL_BOOT_TOKEN=xxx                                 # define via global deployment secrets

export REDIS_ADDR=infra-redis-redis-cluster.infra             # shorf notation is OK
#export REDIS_PASSWORD=xxx                                    # define via global deployment secrets
export REDIS_PORT="6379"

export POSTGRES_ADDR=postgres-std-postgresql.infra  
export POSTGRES_PORT="5432"
export POSTGRES_USER=postgres
#export POSTGRES_PASSWORD=xxx                                 # define via global deployment secrets
export POSTGRES_STD_ADDR=pgdb-std-postgresql.infra
export POSTGRES_GWS_ADDR=pgdb-gws-postgresql.infra
export POSTGRES_DGT_ADDR=pgdb-dgt-postgresql.infra
export POSTGRES_RPTHIST_ADDR=pgdb-rpthist-postgresql.infra
export POSTGRES_RPTRT_ADDR=pgdb-rptrt-postgresql.infra
export POSTGRES_UCSX_ADDR=pgdb-ucsx-postgresql.infra

export MSSQL_ADDR=mssql-deployment.infra
#export MSSQL_ADMIN_PASSWORD=xxx                              # define via global deployment secrets

export KAFKA_ADDR=kafka.infra
export KAFKA_PORT="9092"

export ES_ADDR=elastic-es-http.infra

export INGRESS_CLASS=nginx
export INGRESS_CLASS_INTERNAL=nginx
export CERT_ISSUER=ca-cluster-issuer

export STORAGE_CLASS_RWO=azure-files
export STORAGE_CLASS_RWX=azure-files
export STORAGE_CLASS_RWO_PREMIUM=managed-premium
export STORAGE_CLASS_PROVISIONER=kubernetes.io/azure-file

# These can become handy if you deploy to arbitrary namespaces
# then use these variables in overrides or scripts (for services cross-dependency)
export GAUTH_NAMESPACE=gauth
export GWS_NAMESPACE=gws
export VOICE_NAMESPACE=voice
export IXN_NAMESPACE=ixn
export PULSE_NAMESPACE=pulse
export UCSX_NAMESPACE=ucsx

# Default auth client ids
export auth_client_gws=external_api_client         # gws_client_id in gws
export auth_client_gws_ws=gws-app-workspace        # wrkspc_client_id in gws
export auth_client_gws_prov=gws-app-provisioning   # prov_client_id in gws
export auth_client_tenant=external_api_client      # tenant_gws_client_id in tenant
export auth_client_cxc=cx_contact                  # cxc_gws_client_id in cxc
export auth_client_designer=designer_client        # designer_gws_client_id in designer
export auth_client_ges=ges_client                  # ges_gws_client_id in ges
export auth_client_gcxi=gcxi_client                # gcxi_gws_client_id in gcxi
export auth_client_tlm=gws-app-workspace           # tlm_gws_client_id in tlm
export auth_client_tlmucsx=ucsx_api_client         # ucsx_gws_client_id in ucsx
export auth_client_pulse=pulse_client              # pulse_gws_client_id in pulse

# Additional default global variables
#..
