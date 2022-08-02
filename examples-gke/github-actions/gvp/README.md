![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.


### Prerequisites

Additional manual steps before installation:


1. Database for GVP should be created in postgres (gvp_cm_pg_db_name in deployment-secrets)
2. Database for GVP-RS should be created in MS SQL (gvp_rs_mssql_db_name in deployment-secrets)
3. User with db_owner role for gvp-rs db should be created in MS SQL. (gvp_rs_mssql_admin_password, )
   
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
4. User with db_datareader role for gvp-rs db should be created in MS SQL. (gvp_rs_mssql_reader_password, gvp_rs_mssql_db_password, gvp_rs_mssql_db_user in deployment-secrets)

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




## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 

gvp
--
|Option|Value|
|-|-|
db-hostname |  $gvp_pg_db_server
db-name     |  $gvp_cm_pg_db_name
db-password |  $gvp_cm_pg_db_password
db-username |  $gvp_cm_pg_db_user
username    |  $gvp_cm_configserver_user
password    |  $gvp_cm_configserver_password

### Secrets

`secrets/pullsecret`

`secrets/deployment_secrets`
```
gvp_cm_configserver_password
gvp_cm_configserver_user
gvp_cm_pg_db_name
gvp_cm_pg_db_password
gvp_cm_pg_db_user
gvp_consul_token
gvp_mssql_db_server
gvp_pg_db_server
gvp_rs_mssql_admin_password
gvp_rs_mssql_db_name
gvp_rs_mssql_db_password
gvp_rs_mssql_db_user
gvp_rs_mssql_reader_password
```
## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

