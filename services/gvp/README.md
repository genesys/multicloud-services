[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
[![docs](https://flat.badgen.net/badge/Genesys%20Documentation/GVP/?color=orange)](https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Overview)


# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 


## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage |  :heavy_check_mark: | 
Ingress | -| external https access
Cert manager |  -| optional, for ingress tls
Consul | :heavy_check_mark: |
Kafka | -|
REDIS | -|
DB Server | :heavy_check_mark: |
Elasticsearch |- |


### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`deployment-secrets`

:asterisk: Indicates the variable is mandatory.
|:key: Key|:anchor: Default Value|:pencil2: Sample Value| :book: Description|
|:-|:-:|:-|:-|
gvp_pg_db_server | $POSTGRES_STD_ADDR (global DS)||Postgres GVP DB address
gvp_cm_pg_db_name | "gvp"||Postgres GVP DB name|
gvp_cm_pg_db_user |  $POSTGRES_USER (global DS)||Postgres GVP DB user
gvp_cm_pg_db_password | $POSTGRES_PASSWORD (global DS)||Postgres GVP DB password
gvp_consul_token |  $CONSUL_BOOT_TOKEN (global DS)||Consul API token
gvp_mssql_db_server |  $MSSQL_ADDR from (global DS)||MSSQL GVP reporting server DB address
gvp_rs_mssql_admin_password | $MSSQL_ADMIN_PASSWORD (global DS)||MSSQL GVP RS admin password
gvp_rs_mssql_db_name |  gvp_rs|gvp_rs|MSSQL GVP RS DB name
:asterisk: gvp_cm_configserver_user |  -|default|user for GVP configserver
:asterisk: gvp_cm_configserver_password |-|password |password for GVP configserver
:asterisk: gvp_rs_mssql_db_user | -|gvp|GVP RS DB admin user
:asterisk: gvp_rs_mssql_db_password | -|gvp|GVP RS DB admin password
:asterisk: gvp_rs_mssql_reader_password |  -|gvpreader|GVP RS `mssqlreader` user password

Example `.yaml`

```
apiVersion: v1
kind: Secret
metadata:
  name: deployment-secrets
  namespace: gvp
type: Opaque
stringData:
  gvp_cm_configserver_password: password
  gvp_cm_configserver_user: default
  gvp_rs_mssql_db_password: gvp
  gvp_rs_mssql_db_user: gvp
  gvp_rs_mssql_reader_password: gvpreader
```


### MSSQL DB Creation
1. Database for GVP-RS should be created in MS SQL (gvp_rs_mssql_db_name in deployment-secrets)
2. User with db_owner role for gvp-rs db should be created in MS SQL. (`gvp_rs_mssql_admin_password`, `gvp_rs_mssql_db_name`, `gvp_mssql_db_server`)
   
Example:
```
CREATE LOGIN mssql 
    WITH PASSWORD    = N'password_here',
    DEFAULT_DATABASE = [gvp_rs],
    CHECK_POLICY     = OFF,
    CHECK_EXPIRATION = OFF;
USE [gvp_rs];
GO
CREATE USER mssql FOR LOGIN mssql
GO
EXEC sp_addrolemember N'db_owner', N'mssql'

    GO
```
4. User with db_datareader role for gvp-rs db should be created in MS SQL. (`gvp_rs_mssql_reader_password`, `gvp_rs_mssql_db_password`, `gvp_rs_mssql_db_user` in `deployment-secrets`)

Example:
```
CREATE LOGIN mssqlreader 
    WITH PASSWORD    = N'password_here',
    DEFAULT_DATABASE = [gvp_rs],
    CHECK_POLICY     = OFF,
    CHECK_EXPIRATION = OFF;
USE [gvp_rs];
GO
CREATE USER mssqlreader FOR LOGIN mssqlreader
GO
EXEC sp_addrolemember N'db_datareader', N'mssqlreader'
GO
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

