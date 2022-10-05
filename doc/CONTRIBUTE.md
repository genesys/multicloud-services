[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
# Contribution Guidelines

Below is guidance on how to report issues, propose new features, and submit contributions..
We recommend commit and pull request messages to be clear, concise, and self explanatory.  Please specify related issues when possible.

## Contributing fixes / features

Contributors are welcome to add new services or improve existing deployment code in this repo.   

We recommend these resources to get started with GitHub:

- [Create a free account](https://github.com/)
- [How to fork a repo](https://help.github.com/articles/fork-a-repo)
- [How to create a pull request](https://help.github.com/articles/creating-a-pull-request)

### Before you start, file an issue

Please follow this simple rule to help us eliminate wasted effort & frustration, and ensure an efficient and effective use of everyone's time:

> If you have a question, think you've discovered an issue, would like to propose a new feature, etc., then find/file an issue **BEFORE** starting work to fix/implement it.

#### Search existing issues first

Before filing a new issue, search existing open and closed issues first. It is possible someone else has found the problem you're seeing, and someone may already be working on a solution.

If nothing matches, please file a new issue:

#### File a new Issue

* Don't know whether you're reporting an issue or requesting a feature? - _File an issue_
* Have a question that you don't see answered in the documentation? - _File an issue_
* Want to know if we're planning on building a particular feature? - _File an issue_
* Have an idea for a new feature? - _File an issue/feature request_
* Don't understand how to do something? - _File an issue_
* Found an existing issue that describes yours? - _upvote and add additional info where applicable_

#### Complete the template

**Complete the information requested in the issue template, providing as much information as possible**. The more information you provide, the more likely your issue/ask will be understood and implemented. Helpful information includes:

* What tools and applications you're using.
* Don't assume we're experts in setting up your environment or ditribution, you may need to teach us to help you.
* What steps are needed to reproduce the issue? The more information the better.
* Prefer error message text where possible or screenshots of errors if text cannot be captured
* Prefer text command-line script than screenshots of command-line script.
* **If you intend to implement the fix/feature yourself let us know.** If you do not indicate otherwise we will assume that the issue is ours to solve.

> ⚠ Remember: If you don't have any additional information or context to add, but would like to indicate that you're affected by the issue, upvote the original issue so we may measure how impactful this issue is.

---
## Development

### Fork, Clone, Branch and Create your PR

Once you've discussed your proposed feature/fix/etc... with a team member and been approved, it's time to start development:

1. Fork the repo if you haven't already
1. Clone your fork locally
1. Create & push a feature branch
1. Create a [Draft Pull Request (PR)](https://github.blog/2019-02-14-introducing-draft-pull-requests/) Link to your issue in the PR.
1. Work on your changes
1. Build and see if it works.

### Service contributions
When adding new service, please consider create new folder in `/services` with concise short naming - lowercase letters ("-" and "_" also allowed). 

Existing deployment workflow will be using this new `sample` folder for any operations triggered for service `sample`. Folder must contain `script.sh` with your custom shell script, override values files and any other files necessary for your service's deployment and maintenance. Existing folders are good example.

#### Branch naming
Branch name should start with service name (eg. "gws"), optionally you can add digits at the end (useful when you have several branches like "gws", "gws1", "gws202108"). This is important for PR validation pipeline (see further)

* please limit your changes/contribution to specific service/component folder only. It will help to avoid conflicts at merging.
* workflows should remain simple and if you propose improvements, please discuss it with us. Chances are, we've already considered other options.


### Code Review

When you'd like the team to take a look, mark the PR as 'Ready For Review' so that the team can provide comments, suggestions, and request changes. This is iterative and may take several cycles, with the end result being code that is safe to merge.

> ⚠ Remember: Changes you make may end up being incorporated. Because of this, we treat community PR's with the same levels of scrutiny as commits submitted internally.

---
