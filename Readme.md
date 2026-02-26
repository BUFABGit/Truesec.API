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
The Truesec.API PowerShell module grew out of a simple goal: make it easier, cleaner, and safer to work with Truesec’s REST APIs without constantly rebuilding the same pieces. It takes care of the repetitive parts, authentication, request handling and consistent patterns.
The project began as a way to support Bufab’s internal cybersecurity and automation work and is now being shared publicly to contribute back to the community. Although it’s currently maintained solely by Bufab, the intention is to support openness and collaboration, because sharing really is caring. And as new API features become available, they’ll be added to the module when time allows.


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
Get-TSWorkspace | Initialize-TSWorkspace

# If you have multiple workspaces and want to connect to a specific one using name
Get-TSWorkspace -WorkspaceName "YourWorkspaceName" | Initialize-TSWorkspace

# If you know the id of the workspace you want to connect to
Initialize-TSWorkspace -Id "b65798f1-38a0-4b22-b637-22bbd6929704"
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