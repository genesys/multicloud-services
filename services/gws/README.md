[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
[![docs](https://badgen.net/badge/Genesys%20Documentation/GWS?style=flat&color=orange)](https://all.docs.genesys.com/GWS/Current/GWSPEGuide)

# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/GWS/Current/GWSPEGuide) for the full configuration and deployment details.



## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 

### Notes

## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage | | 
Ingress | :heavy_check_mark: | external https access
Cert manager |  | optional, for ingress tls
Consul | :heavy_check_mark: |
Kafka | - |
REDIS | :heavy_check_mark: |
DB Server | :heavy_check_mark: |
Elasticsearch | :heavy_check_mark: |

### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`deployment_secrets`

:asterisk: Indicates the variable is mandatory.
|:key: Key|:anchor: Default Value|:pencil2: Sample Value| :book: Description|
|:-|:-:|:-|:-|
:asterisk: gws_client_secret| -|`A34BOmXDedZwbTKrwmd4eA==`|**base64 encoded** `gws_client` client secret 
:asterisk: gws_app_provisioning| -|`A34BOmXDedZwbTKrwmd4eA==`|**base64 encoded** `gws_app_provisioning` client secret
:asterisk: gws_app_workspace| -|`A34BOmXDedZwbTKrwmd4eA==`|**base64 encoded** `gws_app_workspace` client secret
LOCATION|  (global DS)
DOMAIN |  (global DS)
POSTGRES_ADDR|  $POSTGRES_GWS_ADDR (global DS)||Postgres address
POSTGRES_USER|  (global DS)||Postgres DB admin user
POSTGRES_PASSWORD|  (global DS)||Postgres DB admin password
REDIS_ADDR|  (global DS)||REDIS address
REDIS_PASSWORD|  (global DS)||REDIS password
ES_ADDR|  (global DS)||Elasticsearch address
gws_consul_token|  $CONSUL_BOOT_TOKEN (global DS)||Consul bootstrap token
gws_client_id|  auth_client_gws (global defaults)|external_api_client|
wrkspc_client_id|  auth_client_gws_ws (global defaults)|gws-app-workspace|
prov_client_id|  auth_client_gws_prov (global defaults)|gws-app-provisioning|
gws_pg_dbname|  gws||GWS DB name
gws_pg_user|  gws||GWS DB user
gws_pg_pass|  gws||GWS DB password
gws_pg_dbname_prov|  prov||GWS provisioning DB name
gws_as_pg_user|  prov||GWS provisioning DB user
gws_as_pg_pass|  prov||GWS provisioning DB password
gws_ops_user|  ops||GWS operations user
gws_ops_pass|  ops||GWS operations password
gws_ops_pass_encr| `$2a$10$GQTt0EfpwGva.0dj5YiRUOvDEL40Eh.iC8tbfK0r7LygRGAgaPyVm`||Encrypted password of the operational user **bcrypt encoded**
gws_set_clients|  false| | Enables Creation of all PE GAUTH Clients [gauth clients](https://all.docs.genesys.com/AUTH/Current/AuthPEGuide/Provision#Create_an_authentication_token)
gws_set_cors|  false|  |  Enables Creation of CORS config in GAUTH Environment [cors](https://all.docs.genesys.com/AUTH/Current/AuthPEGuide/Provision#Update_CORS_settings)
gauth_admin_password_plain| -| | Used only when `gws_set_clients` is set to true
gauth_admin_username| -| | Used only when `gws_set_clients` is set to true


Example `.yaml`

```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: gws
stringData:
    gws_app_provisioning: A34BOmXDedZwbTKrwmd4eA==
    gws_app_workspace: A34BOmXDedZwbTKrwmd4eA==
    gws_client_secret: A34BOmXDedZwbTKrwmd4eA==
```



## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD | | 
Servicemonitors CRD | :heavy_check_mark: | 
Prometheusrules CRD (Alerts) | | :heavy_check_mark:
Configmaps (grafana) | :heavy_check_mark: |
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) | :heavy_check_mark: (on services) |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrate those annotations (disabled by default).

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).
