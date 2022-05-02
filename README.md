# Welcome to the Genesys services pipeline repository

The purpose of this repository is to provide Genesys customers with examples related to Genesys Multicloud CX private edition services.  

Ideal for Demos, Labs or Proof of Concepts. The content provided in this repository cannot be used for QA or Production environments as it is not designed to meet typical HA, DR, multi-region or Security requirements. All content is being provided AS-IS without any SLA, warranty or coverage via Genesys product support.

This repository contains example code for:
* Application service pipelines
* [Third party service pipelines](/third-party)
* [Tools and monitoring](/tools)

Select your cluster type to get started. 
* [generic kubernetes](/examples-generic-kubernetes)
* [GKE](/examples-gke)
* [OpenShift](/examples-openshift)

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
│   │   └── services
│   └── README.md
├── examples-openshift
│   ├── github-actions
│   │   ├── .github/workflow
│   │   └── services
│   └── README.md
├── examples-generic-kubernetes
│   ├── github-actions
│   │   ├── .github/workflow
│   │   └── services
│   └── README.md
├── tools
│   ├── dashboards
│   │   └── grafana
│   │       └── templates
│   └── README.md
└── third-party
    ├── redis
    ├── kafka
    ├── postgresql
    ├── opensearch
    ├── consul
    └── README.md
</pre>

## Related Sites
All service and product documentation can be found at [all.docs.genesys.com](https://all.docs.genesys.com). 

For sample platform reference architectures, please checkout [Genesys Multicloud Platform repository](https://github.com/genesys/multicloud-platform).

## Issues

Find known and resolved issues in the [issue tracker](https://github.com/genesys/multicloud-services/issues).

## Roadmap

Upcoming features and accepted issues can be found on the [project page](https://github.com/genesys/multicloud-services/projects).

## FAQ
Find answers to frequent questions [here](https://github.com/genesys/multicloud-services/wiki/FAQ). 

#### Here is a sample issue someone had

  Cause: This is the root cause to the issue. 

  Solution: Here is how you'd fix this issue. 

## Contributing

We are excited to work alongside our community. 

**BEFORE you begin work**, please read & follow our
[Contribution Guidelines](/doc/CONTRIBUTE.md) to
help avoid duplicate effort.

## Communicating with the Team

The easiest way to communicate with the team is via GitHub [issues](https://github.com/genesys/multicloud-services/issues/new/choose).

Please file new issues, feature requests and suggestions, but **please search for
similar open/closed pre-existing issues before creating a new issue.**

# License

The scripts and documentation in this project are released under the [MIT License](LICENSE)


