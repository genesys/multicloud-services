## Database Configuration 

The examples provided are defined with the following database segmentation. This accomodates functional and operational distinction and mitigates any saturation on a single database within your lab environment. 

**Standard** 
`pg_db_std` 
The base standard database holding config servers for both Tenant/Voice Config Server, GVP Config Server, and Genesys Engagement Server (GES).
**GWS** 
`pg_db_gws` 
The GWS database contains all databased used by GWS, GAuth, as well as Agent Setup.
**UCSX** 
`pg_db_ucsx` 
This single service DB is meant to handle the load that can be produced by a highly populated Contact Database with larger volumes of data.
**Historical Reporting**
`pg_db_rpt_hist`
The Historical Reporting DB is meant to handle load from GIM (GSP/GCA), GCXI, and RAA.
**Real-Time Reporting** 
`pg_db_rpt_rt`
The Real-Time Database is meant to handle a large number of connections required for Pulse and its stat servers.
**Digital** 
`pg_db_dgt`
The Digital database includes the digital specific components. Nexus, IXN, IWD, and IWDDM.

## Additional Info 
The example databases are all deployed within the `infra` namespace. 
The examples leverage a common Helm deployment available through [bitnami](https://github.com/bitnami/charts/tree/master/bitnami/postgresql/#installing-the-chart)

