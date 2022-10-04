[![license](https://badgen.net/badge/license/MIT/blue)](/LICENSE) [![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)

# Welcome to the Genesys services pipeline repository

The purpose of this repository is to provide Genesys customers with examples related to Genesys Multicloud CX private edition services.  

Ideal for Demos, Labs or Proof of Concepts. The content provided in this repository cannot be used for QA or Production environments as it is not designed to meet typical HA, DR, multi-region or Security requirements. All content is being provided AS-IS without any SLA, warranty or coverage via Genesys product support.

#

### Cluster Type
:information_source: Select your cluster type to get started:

<details>
  <summary style="font-size:18px">Generic Kubernetes</summary>

:zap: Quick Start : [GitHub Actions](/doc/gha.md) - [workflow](/doc/examples-k8s.md)    
:gear: Genesys services : [services](/services)         
:sparkles: Third party services : [infra](/services/infra)    
:mag: Observability : [monitoring](/services/monitoring), [logging](/services/logging)    
</details>

<details>
  <summary style="font-size:18px">OpenShift</summary>

:zap: Quick Start : [GitHub Actions](/doc/gha.md) - [workflow](/doc/examples-openshift.md)    
:gear: Genesys services : [services](/services)     
:sparkles: Third party services : [infra](/services/infra)    
:mag: Observability : [monitoring](/services/monitoring), [logging](/services/logging)
</details>

<details>
  <summary style="font-size:18px">GKE</summary>

:zap: Quick Start : [GitHub Actions](/doc/gha.md) - [workflow](/doc/examples-gke.md), [Cloud Build](/doc/cloudbuild.md)    
:gear: Genesys services : [services](/services)     
:sparkles: Third party services : [infra](/services/infra)    
:mag: Observability : [monitoring](/services/monitoring), [logging](/services/logging)    
</details>

#

There are many different CI/CD models available for use, we've included details for those we've had opportunity to work with.

<details open><summary> CI/CD Pipelines</summary>
  
> GitHub Actions : [details](/doc/gha.md)    
> Google Cloud Build : [details](/doc/cloudbuild.md)

</details>

#

Some helpful tools we've used. 

<details open><summary>Tools</summary>
  
> Configuration: [configurator](/tools/configurator)    
> Runner: [Actions Runner Controller](/tools/actions-runner-controller/)    
> Manual Deployment: [manual_deployment.sh](manual_deployment.sh)     

</details>  
  
#

### Repository Structure
<pre>
genesys/multicloud-services
├── google-cloudbuild.yaml
├── .github
│   ├── ISSUE_TEMPLATE
│   │   ├── bug-report.md
│   │   ├── documentation-issue.md
│   │   └── feature-request.md
│   └── workflows
│       ├── deploy_service_aks.yaml
│       ├── deploy_service_gke.yaml
│       ├── deploy_service_k8s.yaml
│       └── deploy_service_openshift.yaml 
├── doc
│   ├── CONTRIBUTE.md
│   ├── DATABASE.md
│   ├── RUNNERS.md
│   ├── ingress.md
│   ├── examples-gke.md
│   ├── examples-openshift.md
│   ├── examples-aks.md
│   ├── examples-k8s.md
│   ├── ingress.md
│   └── STYLE.md
├── services
│   ├── Genesys [service]
│   │   ├── 00_init_[service]
│   │   │   └── script.sh
│   │   ├── 01_chart_[service]
│   │   │   ├── 01_release_[service]
│   │   │   │   ├── init_db.sh
│   │   │   │   ├── pre-release-script.sh
│   │   │   │   ├── post-release-script.sh
│   │   │   │   └── override_values.yaml
│   │   │   ├── override_values.yaml
│   │   │   ├── override_values_<i>azure</i>.yaml
│   │   │   ├── override_values_<i>k8s</i>.yaml
│   │   │   ├── override_values_<i>gke</i>.yaml
│   │   │   ├── override_values_<i>openshift</i>.yaml
│   │   │   └── chart.ver
│   │   ├── 02_chart_[service]-cpe-monitoring
│   │   │   └──  01_release_[service]-cpe-monitoring
│   │   │       ├── alerts
│   │   │       ├── configmaps-dashboards 
│   │   │       ├── deploy-app-dashboards-0.1.0.tgz
│   │   │       ├── override_values.yaml
│   │   │       └── pre-release-script.sh
│   │   └── README.md
│   ├── infra 
│   ├── monitoring
│   └── logging
├── third-party
│   └── README.md
└── tools
    └── configurator
        └── README.md



</pre>

#

## Related Sites
All service and product documentation can be found at [all.docs.genesys.com](https://all.docs.genesys.com). 

For sample platform reference architectures, please checkout [Genesys Multicloud Platform repository](https://github.com/genesysengage/multicloud-platform).

## Issues
Find known and resolved issues in the [issue tracker](https://github.com/genesysengage/multicloud-services/issues).

## Roadmap
Upcoming features and accepted issues can be found on the [project page](https://github.com/genesysengage/multicloud-services/projects).

## FAQ
Find answers to frequent questions in the [discussions section](https://github.com/genesysengage/multicloud-services/discussions). 

## Wiki
Find case studies and cheatsheets within the [wiki section](https://github.com/genesysengage/multicloud-services/wiki).

## Contributing
We are excited to work alongside our community. 

**BEFORE you begin work**, please read & follow our [Contribution Guidelines](/doc/CONTRIBUTE.md) to help avoid duplicate effort.

## Communicating with the Team

The easiest way to communicate with the team is via GitHub [issues](https://github.com/genesysengage/multicloud-services/issues/new/choose).

Please file new issues, feature requests and suggestions, but **please search for similar open/closed pre-existing issues before creating a new issue.**

# License

The scripts and documentation in this project are released under the [MIT License](LICENSE)


