[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)

# Getting Started

This is recommended set of logging tools.
Note that different cloud providers and k8s distributions may provide their own logging suites. For example:
- OpenShift comes with pre-installed EFK stack (Elasticsearch + Fluentd + Kibana),
- GKE Cloud logging is standard logging solution for Google cloud

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Run the github actions workflow for the specific component.

## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage | :heavy_check_mark: | 
Ingress | :heavy_check_mark: | external https access
Cert manager |  | optional, for ingress tls


## Installation
For logging we recommend to use ELK/EFK stack or Grafana Loki.
Install EFK stack via pipeline by installing "logging":

- elasticsearch + kibana (Bitnami distribution)
- fluent-bit

Alternatively (instead of EFK stack) you can install Grafana Loki + promtail
- Loki stack

Remove "x" prefix in folder name and install with "logging loki-stack"

### To install all logging services:
This is the default action of the packaged deployment.   
`install`

To disable a specific installation(s) when using the packaged deployment, preface the directories with `x`.   
**Example**   
`03_chart_loki-stack` to `x03_chart_loki-stack`

### To install specific services:
Use a secondary argument to define the third party service you wish to deploy. 

`validate/install/uninstall chart_name`

Note, the `chart_name` only needs to align with the pattern: `[0-9][0-9]_chart_*$CHART_NAME*/` within the service directory.

Some examples of installation commands:

- `install elasticsearch` (for Elasticsearch)
- `install fluent-bit` (for Fluent-bit)

## Validations

Quick test: all pods should be running in ready state.
Functional tests:
- EFK stack provides Kibana Web UI via ingress https://kibana-logging.<domain>
- Loki stack provides HTTP API via internal service http://loki-stack.<namespace>:3100. Create Loki-type datasource in Grafana and check by queries in Grafana or by making dashboards.


