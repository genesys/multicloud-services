[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
 [![docs](https://flat.badgen.net/badge/Genesys%20Documentation/CXC/orange)](https://all.docs.genesys.com/PEC-OU/Current/CXCPEGuide)
# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/PEC-OU/Current/CXCPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 

## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage |  | 
Ingress |  | external https access
Cert manager |  | optional, for ingress tls
Consul | |
Kafka | |
REDIS | :heavy_check_mark: |
DB Server | :heavy_check_mark: |
Elasticsearch | :heavy_check_mark: |

### Notes
Provisioning is provided by reinstalling cxc release (basically, it is installed twice: `01_release_cxc` and `02_release_cxc`)

Any changes made in `01_release_cxc/override_values.yaml`, must be repeated in `02_release_cxc/override_values.yaml`. 

### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`secrets/deployment-secrets`

:asterisk: Indicates the variable is mandatory.
 
|:key: Key|:anchor: Default Value|:pencil2: Sample Value|:book: Description
|-|:-:|:-|-|
POSTGRES_ADDR | $POSTGRES_GWS_ADDR (global DS)| | |
ES_ADDR| (global DS)| | |
REDIS_ADDR| (global DS)| | |
REDIS_PORT| (global DS)| | |
cxc_redis_password| $REDIS_PASSWORD (global DS)|| Common REDIS password
:asterisk: cxc_gws_client_id |-| cx_contact|
:asterisk: cxc_gws_client_secret|-| secret|
:asterisk: cxc_configserver_user_name|-|cloudcon|
:asterisk: cxc_configserver_user_password|-|cloudcon|
:asterisk: cxc_prov_gwsauthuser|-|ops|
:asterisk: cxc_prov_gwsauthpass|-|ops|
:asterisk: cxc_prov_tenant_user|-|default|
:asterisk: cxc_prov_tenant_pass|-|password|


Example `.yaml`
```
apiVersion: v1
kind: Secret
metadata:
  name: deployment-secrets
  namespace: cxc
type: Opaque
stringData:
  cxc_gws_client_id : cx_contact
  cxc_gws_client_secret: secret
  cxc_configserver_user_name: cloudcon
  cxc_configserver_user_password: CloudContact2017!
  cxc_prov_gwsauthuser: ops
  cxc_prov_gwsauthpass: ops
  cxc_prov_tenant_user: default
  cxc_prov_tenant_pass: password
```
 

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).
