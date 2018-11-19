# What is Automation Easy?

Automation Easy is a framework which contains a library of templates and pre-built solutions.
The goal is to make it easy for everyone to get started using various technologies.

Many aspects of IT needs to be highly customized to the different environments they are going to be leveraged in.
One such example is on- and offboarding of users, which is supported by the User Management Automation solution in Automation Easy.
In such scenarios, the solution is creating a starting point which can be built upon and customized to the specific needs of the organization it is going to be leveraged in.

[![Build Status](https://dev.azure.com/CrayonAS/AutomationEasy/_apis/build/status/PR%20Build)](https://dev.azure.com/CrayonAS/AutomationEasy/_build/latest?definitionId=4)

# Deployment
Deploy the files with [Plaster](https://github.com/PowerShell/Plaster)

```Invoke-Plaster -TemplatePath .\deploy\ -DestinationPath C:\Path\To\Destination\```

for more information, see the deployment [documentation](docs/deploy/deployment-with-plaster.md)

# Contributing
Please do not push directly to the master branch. For Pull Request instructions, please see the contributing [instructions](CONTRIBUTING.md)