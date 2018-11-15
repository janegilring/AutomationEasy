# Contributing

## Documentation

We use [PlatyPS](https://github.com/PowerShell/platyPS) for project documentation and request that new modules are committed with PlatyPS formatted .md files in a docs/modulename folder in the project root. Changes to existing modules should also include updates to the corresponding documentation.

You can generate .md files for your module and/or new functions using `New-MarkdownHelp -Module MyAwesomeModule -OutputFolder .\docs\MyAwesomeModule`

## Pull Request Process

As long as we are on a private repo, pull requests come from separate branches in stead of forks. Pull requests are easy to work with

* Create a new branch locally

  In VSCode, use `Ctrl+Shift+P` and select **Git: Create Branch**. Alternatively in git use

  `git checkout -b branch_name`

* Sync it with the upstream repo

  In VSCode, click the **Publish** action, it's the little cloud with an arrow on it in the status bar

  ![](https://code.visualstudio.com/assets/docs/editor/versioncontrol/git-status-bar-publish.png)

  Or in git

  `git push -u origin branch_name`

* Work and commit code


* Create the PR

  In github, go to the **Pull Requests** tab and select **New pull request**

You can continue working in the same branch after the PR has been merged to master, or delete and create new branches for each PR if you prefer.

## Code of Conduct

### Our Pledge

In the interest of fostering an open and welcoming environment, we as
contributors and maintainers pledge to making participation in our project and
our community a harassment-free experience for everyone, regardless of age, body
size, disability, ethnicity, gender identity and expression, level of experience,
nationality, personal appearance, race, religion, or sexual identity and
orientation.

### Our Standards

Examples of behavior that contributes to creating a positive environment
include:

* Using welcoming and inclusive language
* Being respectful of differing viewpoints and experiences
* Gracefully accepting constructive criticism
* Focusing on what is best for the community
* Showing empathy towards other community members

Examples of unacceptable behavior by participants include:

* The use of sexualized language or imagery and unwelcome sexual attention or
advances
* Trolling, insulting/derogatory comments, and personal or political attacks
* Public or private harassment
* Publishing others' private information, such as a physical or electronic
  address, without explicit permission
* Other conduct which could reasonably be considered inappropriate in a
  professional setting

### Our Responsibilities

Project maintainers are responsible for clarifying the standards of acceptable
behavior and are expected to take appropriate and fair corrective action in
response to any instances of unacceptable behavior.

Project maintainers have the right and responsibility to remove, edit, or
reject comments, commits, code, wiki edits, issues, and other contributions
that are not aligned to this Code of Conduct, or to ban temporarily or
permanently any contributor for other behaviors that they deem inappropriate,
threatening, offensive, or harmful.

### Scope

This Code of Conduct applies both within project spaces and in public spaces
when an individual is representing the project or its community. Examples of
representing a project or community include using an official project e-mail
address, posting via an official social media account, or acting as an appointed
representative at an online or offline event. Representation of a project may be
further defined and clarified by project maintainers.

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be
reported by contacting the project team at [INSERT EMAIL ADDRESS]. All
complaints will be reviewed and investigated and will result in a response that
is deemed necessary and appropriate to the circumstances. The project team is
obligated to maintain confidentiality with regard to the reporter of an incident.
Further details of specific enforcement policies may be posted separately.

Project maintainers who do not follow or enforce the Code of Conduct in good
faith may face temporary or permanent repercussions as determined by other
members of the project's leadership.

### Attribution

This Code of Conduct is adapted from the [Contributor Covenant][homepage], version 1.4,
available at [http://contributor-covenant.org/version/1/4][version]

[homepage]: http://contributor-covenant.org
[version]: http://contributor-covenant.org/version/1/4/