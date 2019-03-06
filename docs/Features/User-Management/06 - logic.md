# PowerShell modules and runbooks

Automation Easy provides the following modules as starting points:

- User.Management.Automation.Core - Generic commands which can be leveraged across scenarios
- User.Management.Automation - Commands for on- and offboarding of users based on requests stored in Sharepoint-lists
- User.Management.Automation.Sync- Commands for on- and offboarding of users based on data in an HR database

Automation Easy provides the following runbooks as starting points:

- New-UMUser - For scenario 1 (frontend) - leverages the User.Management.Automation module for performing actions.
- Sync-UMUser - For scenario 2 (HR-sync) - leverages the User.Management.Automation.Sync module for performing actions.

Both the modules and the runbooks is meant as starting points, and must be customized in most cases based on the required logic and workflow defined for user management process in the company.

This project will most likely be a "live" project with continous updates, and will benefit of a structured infrastructure. The recommended approach is to put all modules and runbooks in a version control system, and publish them to Azure Automation (and the Hybrid Runbook Workers, if used) in a Release Pipeline.

*Note:* The UM-prefix (short for User Management) is optional, and may be replaced with a company interal prefix instead.
A benefit of keeping the prefix is that customizations made can be defined in a custom module, while still being able to leverage updated versions from the Automation Easy framework in the future. If both the Automation Easy-provided and the custom-made module version containing the same command names is imported in a runbook, the latest module imported will be used (the -AllowClobber switch must be specified in order to allow this scenario).