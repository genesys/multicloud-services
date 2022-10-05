[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
[![docs](https://flat.badgen.net/badge/Genesys%20Documentation/GSP/?color=orange)](https://all.docs.genesys.com/PEC-REP/Current/GIMPEGuide/Overview)

# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/PEC-REP/Current/GIMPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 

Note:
OpenShift supports dynamic binding using an [Object Bucket Claim](https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.6/html/managing_hybrid_and_multicloud_resources/object-bucket-claim). The Object Bucket is created in OpenShift on-the-fly in the `pre-release-script`. 

## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage |:heavy_check_mark: | S3 Bucket
Ingress |  | external https access
Cert manager |  | optional, for ingress tls
Consul | |
Kafka |:heavy_check_mark: |
REDIS |  |
DB Server |  |
Elasticsearch | |

### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`deployment_secrets`

:asterisk: Indicates the variable is mandatory.

|:key: Key|:anchor: Default Value|:pencil2: Sample Value| :book: Description|
|:-|:-:|:-|:-|
KAFKA_ADDR | (global DS)|kafka.kafka|Kafka address
:asterisk: gsp_s3_bucket_host |  -|storage.googleapis.com|S3 Bucket host address. (optional for OpenShift)
:asterisk: gsp_s3_bucket_port |  -|443|S3 access port. (optional for OpenShift)
:asterisk: gsp_s3_bucket_name |  -|gca-gsp-storage-bucket|S3 bucket name. (optional for OpenShift)
:asterisk: gsp_s3_access_key |  -|access_key|S3 access key. (optional for OpenShift)
:asterisk: gsp_s3_secret_key |  -|secret_key|S3 secret. (optional for OpenShift)
gsp_azure_wasb_host | - | gspwestus2aks.blob.core.windows.net |mandatory for AKS


Example `.yaml`

```
apiVersion: v1
kind: Secret
metadata:
  name: deployment-secrets
  namespace: gsp
type: Opaque
stringData:
  KAFKA_ADDR: kafka.kafka
  gsp_s3_access_key: access_key
  gsp_s3_secret_key: secret_key
  gsp_s3_bucket_host: storage.googleapis.com
  gsp_s3_bucket_port: 443
  gsp_s3_bucket_name: gca-gsp-storage-bucket
```



## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|-|-|
Podmonitors CRD | | 
Servicemonitors CRD |  | 
Prometheusrules CRD (Alerts) | | 
Configmaps (grafana) |  |
Grafanadashboards CRD | | 
Prometheus annotations (*) |  (on services) |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrape those annotations (disabled by default).

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).