[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
[![docs](https://flat.badgen.net/badge/Genesys%20Documentation/IWDEM/?color=orange)](https://all.docs.genesys.com/PEC-Email/Current/EmailPEGuide)

# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/PEC-Email/Current/EmailPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret `deployment-secrets` to store confidential information you may not want held in your repository, or `.yaml` files. 
## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage | | 
Ingress | | external https access
Cert manager |  | optional, for ingress tls
Consul | |
Kafka | |
REDIS | :heavy_check_mark:|
DB Server |  |
Elasticsearch | |
### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`deployment-secrets`


:asterisk: Indicates the variable is mandatory.
|:key: Key|:anchor: Default Value|:pencil2: Sample Value| :book: Description|
|:-|:-:|:-|:-|
:asterisk: iwdem_nexus_api_key|-|565c12cb-cdae-4141-881d-c91cd55082c2
REDIS_ADDR|  (global DS)
REDIS_PORT|  (global DS)
REDIS_PASSWORD|  (global DS)

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: iwdem
stringData:
  iwdem_nexus_api_key: **as generated in Nexus** 565c12cb-cdae-4141-881d-c91cd55082c2
```
### Notes

Notes:
iwdem_nexus_api_key - look it up in Nexus DB, table nex_apikeys.

`iwdem_nexus_api_key` should be created using nexus API.
*You will be using your own unique tenant UUID and gauth client_id*

```
# Acquire bearer token
curl --location --request POST 'https://gauth.apps.<domain>/auth/v3/oauth/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Authorization: Basic ***' \
--data-urlencode 'username=***' \
--data-urlencode 'client_id=external_api_client' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'password=***'
```
```
# Acquire nexus API key 
curl --location --request POST 'https://nexus.<domain>/nexus/v3/apikeys' \
--header 'Authorization: Bearer ***token***' \
--header 'Content-Type: application/json' \
--header 'Cookie: ***cookie***' \
--data-raw '{"data": {
"enabled": true,
"tenant": "9350e2fc-a1dd-4c65-8d40-1f75a2e00100",
"name": "IWDEM API key for t100",
"permissions": [
"nexus:consumer:*"
]}}'
```
## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD | :heavy_check_mark:| 
Servicemonitors CRD | | 
Prometheusrules CRD (Alerts) | :heavy_check_mark:| 
Configmaps (grafana) | :heavy_check_mark:| 
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) | |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrape those annotations (disabled by default).


## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).

