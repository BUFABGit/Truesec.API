## Table of Contents

- [Table of Contents](#table-of-contents)
- [About The Project](#about-the-project)
  - [Built With](#built-with)
- [Getting started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Connecting](#connecting)
    - [Connecting with a pscredential object](#connecting-with-a-pscredential-object)
    - [Connect using the 1password CLI](#connect-using-the-1password-cli)
    - [Connect using KeePass 2](#connect-using-keepass-2)
  - [Workspaces](#workspaces)
- [Help](#help)

<!-- ABOUT THE PROJECT -->
## About The Project
At Bufab Global IT, we’ve learned and grown thanks to the open‑source community and its spirit of sharing is caring. If this project helps you in any way, then we’re happy to return the favor and give back. 😊

### Built With

* [Powershell](https://docs.microsoft.com/en-us/powershell/)
* [VSCode](https://code.visualstudio.com/)
* [Truesec Portal API](https://api.soc.truesec.app/index.html)


<!-- GETTING STARTED -->
## Getting started

### Prerequisites
* Powershell 5.1 or higher version
* API credentials provided by Truesec
* Optional: 1Password CLI, KeePass 2

### Setup
Clone the repo
```sh
git clone https://github.com/BUFABGit/Truesec.API.git
```
or just download it as a zip package



### Connecting
There are a couple of different way to connect to the Truesec API using this module. Choose which ever suits you best.

#### Connecting with a pscredential object
```powershell
# Import the module
Import-Module .\Truesec.API.psd1

# Build the credential object
$Credential = Get-Credential

# Connect to the API
Connect-TruesecAPI -Credential $Credential
```

#### Connect using the 1password CLI
```powershell
# Import the module
Import-Module .\Truesec.API.psd1

# Connect to the API where APIKeyName is the name of the entry in 1password holding your API credentials. Exact match is expected.
Connect-TruesecAPI -APIKeyName "Truesec API credentials"
```

#### Connect using KeePass 2
```powershell
*** Currently only supported in powershell 5.1 ***
# Import the module
Import-Module .\Truesec.API.psd1

# Connect to the API where APIKeyName is the name of the entry in 1password holding your API credentials.
# The KeePassDB parameter expect an exact path to your database file.
Connect-TruesecAPI -APIKeyName "Truesec API credentials" -KeePassDB "C:\Temp\Database.kdbx"

# If you've installed KeePass in a different location than the default one (C:\Program Files\KeePass Password Safe 2\KeePass.exe), you can provide that path with the KeePassPath parameter
Connect-TruesecAPI -APIKeyName "Truesec API credentials" -KeePassPath "C:\Somewhere\else\KeePass.exe" -KeePassDB "C:\Temp\Database.kdbx"

# You will be prompted for a password to the database file.
```

### Workspaces
Once you're connected and have maintained an access token, it's time to set the workspace.
```powershell
# If you only have one workspace
Get-TSWorkspace | Set-TSWorkspace

# If you have multiple workspaces and want to connect to a specific one using name
Get-TSWorkspace -WorkspaceName "YourWorkspaceName" | Set-TSWorkspace

# If you know the id of the workspace you want to connect to
Set-TSWorkspace -Id "b65798f1-38a0-4b22-b637-22bbd6929704"
```

Once the workspace is initialized, you're ready to start using the other cmdlets!
```powershell
# Get all incidents with status Unresolved
$UnresolvedIncidents = Get-TSIncident -All -Status Unresolved

# Get all threat events
$ThreatEvents = Get-TSThreatEvent -All

# Get a cyber exposure profile by id
$CyberExposureProfile = Get-TSCyberExposureProfile -Id "2f8c70d2-8a85-4c40-adcb-8b1eecd30d2a"
```

## Help
You can utilize the built in help cmdlet in powershell
```powershell
# Get examples for the Get-TSIncident cmdlet
Get-Help -Name Get-TSIncident -Examples

# Get full cmdlet documentation for Get-TSThreatEvent
Get-Help -Name Get-TSThreatEvent -Full
```
For more detailed information and examples around using the modules functions, please see [/Docs](/Docs/)
## Changes

### 1.1.0 (2026-10-19)
- **Breaking:** `Get-TSIncident`, `Get-TSThreatEvent` and `Get-TSCyberExposureProfile` now **throw** when a request
  fails, with a cleaned message (`Truesec API request failed: GET /workspaces/.../incidents (HTTP 403). ...`).
  Before, they wrote an error and returned the request parameters, which included the `Authorization` header with
  the bearer token in plain text. Catch the exception (`try { ... } catch { ... }`) where you handled the old output.
- The module loads on Linux (paths built with `Join-Path`), so it can run in Azure Functions.
- `Set-TSWorkspace` configures the requested workspace (it used the first one returned).
- The token request throws its own error (not `$Error[0]`), without the client secret.
- Status messages ("Current token still active.", "Workspace already configured.") go to the verbose stream instead of
  the output.
- `Get-QueryString` sends `pageSize` in lower camel case.
- Pester tests: `Invoke-Pester ./Tests/Truesec.API.Tests.ps1`.
