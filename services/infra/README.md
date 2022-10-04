# Getting Started

The sample service deployments for third party tools are provided to allow for customized deployments of third party services. They are not intended to supplant or replace the foundational infrastructure. 

For platform provisioning please see: [multicloud-platform](https://github.com/genesys/multicloud-platform)

Consult with the individual third party resource for their full configuration and deployment details.

## TL;DR
- Complete the prerequisites if any.
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
- elasticsearch
- kafka
- consul
- opensearch (optional)

### To install all infra services:
This is the default action of the packaged deployment.   
`install`

To disable a specific installation(s) when using the packaged deployment, preface the directories with `x`.   
**Example**   
`04_chart_elasticsearch` to `x04_chart_elasticsearch`

### To install specific services:
Use a secondary argument to define the third party service you wish to deploy. 

`validate/install/uninstall chart_name`

Note, the `chart_name` only needs to align with the pattern: `[0-9][0-9]_chart_*$CHART_NAME*/` within the service directory.

Some examples of installation commands:

- `install mssql` (for MS SQL)
- `install postgres` (for Postgres)
- `install redis` (for Redis)
- `install elastic` (for Elasticsearch - requires licensing)
- `install cp-helm` (for Kafka)
- `install consul` (for Consul)


## Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

## Additional Information
