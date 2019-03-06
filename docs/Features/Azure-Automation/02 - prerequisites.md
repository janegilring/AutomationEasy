# Prerequisites

In order to leverage Azure Automation Process Automation with a Hybrid Runbook Worker, the following prerequisites needs to be in place:

- An Azure subscription (note: Azure Automation is currently not supported in Azure Stack)
- A server running Windows Server 2012 R2 or later, with connectivity to the on-premises network
- TCP port 443 open outbound from the server(s) to be configured as Hybrid Runbook Workers
- Optionally, a service account to be used for automation against on-premises systems such as Active Directory
