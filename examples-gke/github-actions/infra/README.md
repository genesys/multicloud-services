# Getting Started

The sample service deployments for third party tools are provided to allow for customized deployments of third party services. They are not intended to supplant or replace the foundational infrastructure. 

For platform provisioning please see: [multicloud-platform](https://github.com/genesys/multicloud-platform)

Consult with the individual third party resource for their full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Run the github actions workflow for the specific component.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 

## Installation
The third party services are deployed as follows:

- mssql
- postgres
- redis
- opensearch
- kafka
- consul
- elasticsearch (optional)
### To install all infra services:
This is the default action of the packaged deployment.   
`install`

To disable a specific installation(s) when using the packaged deployment, preface the directories with `x`.   
**Example**   
`07_chart_elasticsearch` to `x07_chart_elasticsearch`
### To install specific services:
Use a secondary argument to define the third party service you wish to deploy. 

`validate/install/uninstall chart_name`

Note, the `chart_name` only needs to align with the pattern: `[0-9][0-9]_chart_*$CHART_NAME*/` within the service directory.

Some examples of installation commands:

- `install postgres` (for Postgres)
- `install redis` (for Redis)
- `install opensearch` (for OpenSearch - free fork of Elasticsearch)
- `install cp-helm` (for Kafka)
- `install consul` (for Consul)
- `install mssql` (for MS SQL)
- `install elastic` (for ElasticSearch - requires licensing)

## Database Structure
For additional detail: [Database Configuration](../../../doc/DATABASE.md)

With the installation command `install postgress`, by default all six instances are installed (pgdb-std, pgdb-gws, pgdb-dgtl, pgdb-rpthist, pgdb-rptrlt, pgdb-ucsx) 

To install a distinct instance of postgres, define the specific db name in the command string.

This is true for all commands: validate/install/uninstall
`validate/install/uninstall postgres instance_name`

For example, to install the GWS database (pgdb-gws):
`install postgress gws` 

## Secrets 
Create the [standard pullsecret](../#-considerations) for the workflow: 
`secrets/pullsecret`

## Additional Information
