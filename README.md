# Welcome to the Genesys services pipeline repository

The purpose of this repository is to provide Genesys customers with examples related to Genesys Multicloud CX private edition services.  

Ideal for Demos, Labs or Proof of Concepts. The content provided in this repository cannot be used for QA or Production environments as it is not designed to meet typical HA, DR, multi-region or Security requirements. All content is being provided AS-IS without any SLA, warranty or coverage via Genesys product support.

### Select your cluster type to get started. This repository contains example code for:

* [Generic kubernetes](/examples-generic-kubernetes)
    * Genesys services - [services](/examples-generic-kubernetes/github-actions)
    * Third party services - [infra](/examples-generic-kubernetes/github-actions/infra)
    * Observability - [monitoring](/examples-generic-kubernetes/github-actions/monitoring), [logging](/examples-generic-kubernetes/github-actions/logging)

* [GKE](/examples-gke)
    * Genesys services - [services](/examples-gke/github-actions)
    * Third party services - [infra](/examples-gke/github-actions/infra)
    * Observability - [monitoring](/examples-gke/github-actions/monitoring), [logging](/examples-gke/github-actions/logging)

* [OpenShift](/examples-openshift)
    * Genesys services - [services](/examples-openshift/github-actions) 
    * Third party services - [infra](/examples-openshift/github-actions/infra)
    * Observability - [monitoring](/examples-openshift/github-actions/monitoring), [logging](/examples-openshift/github-actions/logging)
 
* [Tools](/tools)
  * Grafana - [dashboard templates](/tools/grafana-dashboards)

## Respository Structure
<pre>
genesys/multicloud-services
├── .github
│   └── ISSUE_TEMPLATE
│       ├── bug-report.md
│       ├── documentation-issue.md
│       └── feature-request.md
├── doc
│   ├── CONTRIBUTE.md
│   └── STYLE.md
├── examples-gke
│   ├── github-actions
│   │   ├── .github/workflow
│   │   ├── services
│   │   ├── third party
│   │   └── observability
│   └── README.md
├── examples-openshift
│   ├── github-actions
│   │   ├── .github/workflow
│   │   ├── services
│   │   ├── third party
│   │   └── observability
│   └── README.md
├── examples-generic-kubernetes
│   ├── github-actions
│   │   ├── .github/workflow
│   │   ├── services
│   │   ├── third party
│   │   └── observability
│   └── README.md
└── tools
    └──grafana-dashboards
       ├── overlays
       ├── templates
       └── README.md


</pre>

## Related Sites
All service and product documentation can be found at [all.docs.genesys.com](https://all.docs.genesys.com). 

For sample platform reference architectures, please checkout [Genesys Multicloud Platform repository](https://github.com/genesysengage/multicloud-platform).

## Issues

Find known and resolved issues in the [issue tracker](https://github.com/genesysengage/multicloud-services/issues).

## Roadmap

Upcoming features and accepted issues can be found on the [project page](https://github.com/genesysengage/multicloud-services/projects).

## FAQ
Find answers to frequent questions in the [discussions section](https://github.com/genesysengage/multicloud-services/discussions). 

## Contributing

We are excited to work alongside our community. 

**BEFORE you begin work**, please read & follow our [Contribution Guidelines](/doc/CONTRIBUTE.md) to help avoid duplicate effort.

## Communicating with the Team

The easiest way to communicate with the team is via GitHub [issues](https://github.com/genesysengage/multicloud-services/issues/new/choose).

Please file new issues, feature requests and suggestions, but **please search for similar open/closed pre-existing issues before creating a new issue.**

# License

The scripts and documentation in this project are released under the [MIT License](LICENSE)


