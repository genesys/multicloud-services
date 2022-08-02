# Getting Started

This is recommended set of monitoring tools.
Note that different cloud providers and k8s distributions may provide their own monitoring suites. For example:
- Openshift comes with pre-installed EFK stack (Elasticsearch + Fluentd + Kibana),
- GKE Cloud logging is standard logging solution for Google cloud,
- and in MicroK8s distribution you can easily setup prometheus-based monitoring by "microk enable prometheus"

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Run the github actions workflow for the specific component.

## Installation
Services are deployed altogether as follows:

- [prometheus stack](https://github.com/prometheus/prometheus)
- [grafana operator](https://github.com/grafana/grafana)
- [robusta](https://github.com/robusta-dev/robusta) 

### To install all infra services:
This is the default action of the packaged deployment.   
`install`

To disable a specific installation(s) when using the packaged deployment, preface the directories with `x`.   
**Example**   
`01_chart_kube-prometheus-stack` to `x01_chart_kube-prometheus-stack`

### To install specific services:
Use a secondary argument to define the third party service you wish to deploy. 

`validate/install/uninstall chart_name`

Note, the `chart_name` only needs to align with the pattern: `[0-9][0-9]_chart_*$CHART_NAME*/` within the service directory.

Some examples of installation commands:

- `install kube-prometheus-stack` (for Prometheus stack)
- `install grafana-operator` (for Grafana)
- `install robusta` (for Robusta)

