# Prerequisites

In order to leverage the User Management Automation solution, the following prerequisites needs to be in place:

- An Azure subscription
- A service account to be used for automation against on-premises systems such as Active Directory
- A service account or Azure AD Service Principal (recommended) to be used for automation against cloud services such as Azure AD and Office 365
- Sharepoint license for the service account
- PowerApps license for users which should be consumers of the on/offboarding PowerApps (typically managers within the organization)
- Optionally, but highly recommended:
    - Source control *(examples: Azure DevOps, GitHub, GitLab)*
    - Continous integration/continous delivery service *(examples: Azure DevOps, GitLab, Jenkins, TeamCity)*

The following resources can be deployed using the templates and scripts provided:

- Azure Automation account, optionally with a Hybrid Runbook Worker
    - Recommended specifications for the worker server: 2 vCPUs, 4 GB RAM, 100 GB OS disk
- Log Analytics workspace (Log Analytics is now a part of Azure Monitor)
- Azure Logic Apps
    - Onboarding
    - Offboarding
- PowerApps
    - Onboarding
    - Offboarding
- Sharepoint site (a dedicated sub site for IT Automation is recommended)
- Sharepoint lists
    - Onboarding
    - Offboarding
    - Metadata
        - Company
        - Department

If deploying scenario 2 (synchronizing users between an HR database and Active Directory), the Logic Apps and PowerApps is not needed.
