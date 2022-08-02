# Getting Started

This is recommended set of logging tools.
Note that different cloud providers and k8s distributions may provide their own logging suites. For example:
- Openshift comes with pre-installed EFK stack (Elasticsearch + Fluentd + Kibana),
- GKE Cloud logging is standard logging solution for Google cloud

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Run the github actions workflow for the specific component.

## Installation
For logging we recommend to use ELK/EFK stack or Grafana Loki.
Install EFK stack via pipeline by installing "logging":

- elasticsearch + kibana (Bitnami distribution)
- fluent-bit

Alternatively (instead of EFK stack) you can install Grafana Loki + promtail
- loki stack

Remove "x" prefix in folder name and install with "logging loki-stack"

### To install all infra services:
This is the default action of the packaged deployment.   
`install`

To disable a specific installation(s) when using the packaged deployment, preface the directories with `x`.   
**Example**   
`01_chart_elasticsearch` to `x01_chart_elasticsearch`

### To install specific services:
Use a secondary argument to define the third party service you wish to deploy. 

`validate/install/uninstall chart_name`

Note, the `chart_name` only needs to align with the pattern: `[0-9][0-9]_chart_*$CHART_NAME*/` within the service directory.

Some examples of installation commands:

- `install loki-stack` (for Loki stack)
- `install fluent-bit` (for Fluent-bit)
