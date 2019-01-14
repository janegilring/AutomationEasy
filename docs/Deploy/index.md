# Deployment with Plaster

We have built possibility to deploy the files using [Plaster](https://github.com/PowerShell/Plaster). In it's simplest form this can be done with

```Invoke-Plaster -TemplatePath .\deploy\ -DestinationPath C:\Path\To\Destination\```

after which Plaster will ask for information that needs to be changed in each deployment.

![mkdocs](../img/plaster_demo.gif)

## Plaster parameters

### FeatureSelect

A list of the features to install

```yaml

Type: multichoice

Required: true
Default value: "[UserManagement,AzureAutomation]"

```

### AzureADConnectServer

FQDN of the Azure AD connect server in the environment.

```yaml

Type: text

Required: true
Default value: "SERVER01"

```

### AzureADPremiumLicenseWarningThreshold

A threshold for AzureAD Premium license remaining warnings

```yaml

Type: text

Required: true
Default value: "3"

```

### Office365E3LicenseWarningThreshold

A threshold for Office 365 E3 license remaining warnings

```yaml

Type: text

Required: true
Default value: "3"

```

### MSTeamsUserManagementNotificationsWebhookURL

The webhook URL from the MS Teams channel that will recive notifications from the system

```yaml

Type: text

Required: true
Default value: "https://outlook.office.com/webhook/xxx/yyy/zzz"

```

### MSTeamsUserManagementWarningNotificationsWebhookURL

The webhook URL from the MS Teams channel that will recive license remaining warning notifications from the system, based on [AzureADPremiumLicenseWarningThreshold](###AzureADPremiumLicenseWarningThreshold) and [Office365E3LicenseWarningThreshold](###Office365E3LicenseWarningThreshold) values

```yaml

Type: text

Required: true
Default value: "https://outlook.office.com/webhook/xxx/yyy/zzz"

```

### SharePointAutomationSiteURL

URL of the Sharepoint site that will contain the configuration

```yaml

Type: text

Required: true
Default value: "https://contoso.sharepoint.com/ITAutomation"

```

### SharePointAutomationEmailContentListName

Name of the Sharepoint list that will contain the email content

```yaml

Type: text

Required: true
Default value: "Email Content"

```

### SharePointCompanyListName

Name of the Sharepoint list that will contain the company configuration

```yaml

Type: text

Required: true
Default value: "Company"

```

### SharePointDepartmentListName

Name of the Sharepoint list that will contain the company configuration

```yaml

Type: text

Required: true
Default value: "Department"

```