function Connect-TruesecAPI {
<#
.SYNOPSIS
Connects to the Truesec API by establishing API credentials and optionally obtaining a new access token.

.DESCRIPTION
Connect-TruesecAPI initializes API credentials used by the Truesec module and, if required, acquires a new access token.
You can provide the API credentials in three ways:
- **Manual**: Pass a PSCredential that contains the API username and key/secret.
- **1Password**: Retrieve the API key using the 1Password CLI (requires `op.exe` on PATH) by specifying the name of the entry holding the key.
- **KeePass**: Retrieve the API key from a KeePass database by providing the KeePass executable path (if not default), the database file path, and the KeePass database password.

The function stores the credential in `$Script:TruesecSettings.Session.ApiCredentials`. If a new token is needed, it calls `Get-AccessToken` using the stored credentials.

.PARAMETER Credential
Manual mode. A PSCredential containing the API username (UserName) and API key/secret (Password).
Mandatory in the **Manual** parameter set.

.PARAMETER APIKeyName
Name of the vault entry that contains the API key/secret.
- In the **1Password** parameter set, this is the item name passed to the 1Password CLI.
- In the **KeePass** parameter set, this is the entry name in the KeePass database.
Mandatory in the **1Password** and **KeePass** parameter sets.

.PARAMETER KeePassPath
Path to `KeePass.exe`. If a folder is supplied, the function appends `KeePass.exe`.
Defaults to `C:\Program Files\KeePass Password Safe 2\KeePass.exe`.
Optional; only used in the **KeePass** parameter set.

.PARAMETER KeePassDB
Full path to the KeePass database file (`.kdbx`) containing the API key entry.
Mandatory in the **KeePass** parameter set.

.PARAMETER KeePassPW
Password for the KeePass database as a SecureString.
Mandatory in the **KeePass** parameter set.

.INPUTS
None. You cannot pipe objects directly to Connect-TruesecAPI.

.OUTPUTS
None. This cmdlet does not produce pipeline output.
Side effects:
- Sets `$Script:TruesecSettings.Session.ApiCredentials`.
- May obtain and cache a new access token (via `Get-AccessToken`) if `Confirm-NeedNewAccessToken` evaluates to true.

.EXAMPLE
PS> Connect-TruesecAPI -Credential (Get-Credential)
Uses a manually supplied PSCredential to set the API credentials and, if required, fetches a new access token.

.EXAMPLE
PS> Connect-TruesecAPI -APIKeyName "Truesec API Key (Prod)" -Verbose
Retrieves the API key from the 1Password CLI using the specified item name and sets the credentials. Requires `op.exe` to be installed and available on PATH.

.EXAMPLE
PS> $kpw = Read-Host "KeePass DB Password" -AsSecureString
PS> Connect-TruesecAPI -APIKeyName "Truesec API Key (Prod)" -KeePassDB "C:\Secrets\vault.kdbx" -KeePassPW $kpw
Fetches the API key from the KeePass database and sets the credentials. Uses the default KeePass installation path.

.NOTES
Author: Bufab Global IT, Cybersecurity department
Requirements:
- **1Password** parameter set needs 1Password CLI (`op.exe`) installed and on PATH.
- **KeePass** parameter set currently supports Windows PowerShell 5.1 only. The cmdlet throws if PS major version > 5.
- The function validates KeePass paths and database existence before attempting retrieval.

.LINK
Get-AccessToken
.LINK
Get-ApiKey
.LINK
Confirm-NeedNewAccessToken
#>
    [CmdletBinding()]
    param (
        # Parameter help description
		[Parameter(
			Mandatory = $true,
			ParameterSetName = "Manual"
		)]
		[pscredential]
		$Credential,

		# Use this parameter if you intend to utilize the 1Password CLI to retrieve the API key that way. Feed the parameter the name of the entry in 1Password that holds your API key.
		[Parameter(
			Mandatory = $true,
			ParameterSetName = "1Password"
		)]
		[Parameter(
			Mandatory = $true,
			ParameterSetName = "KeePass"
		)]
		[string]
		$APIKeyName,

		# KeePass exe path
		[Parameter(
			Mandatory = $false,
			ParameterSetName = "KeePass"
		)]
		[string]
		$KeePassPath = 'C:\Program Files\KeePass Password Safe 2\KeePass.exe',

		# Path to the keepass db file
		[Parameter(
			Mandatory = $true,
			ParameterSetName = "KeePass"
		)]
		[string]
		$KeePassDB,

		# KeePass password
		[Parameter(
			Mandatory = $true,
			ParameterSetName = "KeePass"
		)]
		[securestring]
		$KeePassPW
    )
    
    begin {
        
    }
    
    process {
        if (-not $Script:TruesecSettings.Session.ApiCredentials) {
			switch ($PSCmdlet.ParameterSetName) {
				Manual {
					# $ApiCredentials = [pscredential]::new($ApiUserName,$ApiKey)
					$Script:TruesecSettings.Session.ApiCredentials = $Credential
				}
				1Password {
					# Check if the 1Password CLI is available
					if (-not (op.exe)) {
						throw "1Password CLI not found. Please install it and ensure it's in your system PATH."
					}
					$Script:TruesecSettings.Session.ApiCredentials = $(Get-ApiKey -Source 1Password -APIKeyName $APIKeyName)
				}
				KeePass {
					if ($PSVersionTable.PSVersion.Major -gt 5) {
						throw "Currently the highest supported powershell version is 5.1. You're running: $($PSVersionTable.PSVersion)"
					}
					if (-not (Test-Path -Path $KeePassPath)) {
						throw "KeePass not found. Please provide the correct path and try again."
					}

					if (-not ($KeePassPath -match "KeePass.exe")) {
						$KeePassPath = Join-Path -Path $KeePassPath -ChildPath "KeePass.exe"
					}

					if (-not (Test-Path -Path $KeePassDB)) {
						throw "KeePass database not found: $KeePassDB"
					}
					$Script:TruesecSettings.Session.ApiCredentials = $(Get-ApiKey -Source KeePass -APIKeyName $APIKeyName -KeePassPath $KeePassPath -KeePassDB $KeePassDB -KeePassPW $KeePassPW)
				}
			}
		}
		if (Confirm-NeedNewAccessToken) {
			Get-AccessToken -APICredentials $Script:TruesecSettings.Session.ApiCredentials
		}
    }
    
    end {
        
    }
}
# End function.