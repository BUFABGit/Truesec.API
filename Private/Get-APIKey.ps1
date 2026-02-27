function Get-ApiKey {
<#
.SYNOPSIS
Retrieves API credentials (username + secret) from a specified secure source.

.DESCRIPTION
Get-ApiKey returns a PSCredential containing the API username and secret from one of the supported sources:
- **1Password**: Uses the 1Password CLI (`op`) to read a vault item and extract the username and password.
- **KeePass**: Loads the KeePass assemblies, opens the specified `.kdbx` database, searches for an entry by name, and extracts the username and password.
- **Internal**: Reserved for future implementations (e.g., secure internal store).

The resulting credential is typically saved to `$Script:TruesecSettings.Session.ApiCredentials` by callers and later used by Get-AccessToken.

.PARAMETER Source
Specifies where the API key should be retrieved from.
Valid values:
- 1Password
- KeePass
- Internal

Mandatory.

.PARAMETER APIKeyName
The entry name containing the API key/secret:
- For **1Password**: the item name in the vault.
- For **KeePass**: the entry title to search for in the database.

Mandatory for **1Password** and **KeePass** parameter sets.

.PARAMETER KeePassPath
Path to the KeePass executable/assembly used to load the required KeePass types.
Mandatory for the **KeePass** parameter set.

.PARAMETER KeePassDB
Full path to the KeePass database file (`.kdbx`).
Mandatory for the **KeePass** parameter set.

.PARAMETER KeePassPW
SecureString password for the KeePass database.
Mandatory for the **KeePass** parameter set.

.INPUTS
None. This cmdlet does not accept pipeline input.

.OUTPUTS
System.Management.Automation.PSCredential  
A credential object whose UserName is the API client id and whose Password is the API secret.

.EXAMPLE
PS> Get-ApiKey -Source 1Password -APIKeyName "Truesec API Key (Prod)"
Fetches the API credential from a 1Password item and returns it as a PSCredential.

.EXAMPLE
PS> $kpw = Read-Host "KeePass DB Password" -AsSecureString
PS> Get-ApiKey -Source KeePass -APIKeyName "Truesec API Key (Prod)" -KeePassPath "C:\Program Files\KeePass Password Safe 2\KeePass.exe" -KeePassDB "C:\Secrets\vault.kdbx" -KeePassPW $kpw
Opens the KeePass database, locates the specified entry, and returns the API credential.

.NOTES
Author: Bufab Global IT, Cybersecurity department

Requirements & Behavior:
- `$Script:TruesecSettings` must be initialized before calling this cmdlet.
- **1Password**: Requires the 1Password CLI (`op`) to be installed and available on PATH. The item must contain a *username* field and a *password* field.
- **KeePass**: Loads KeePass assemblies from the provided path, opens the database with the given password, searches by entry title, and constructs a PSCredential from the entry’s UserName and Password fields.
- **Internal**: Placeholder for future use; currently returns nothing.
- On failure (e.g., item not found, file/path errors, CLI/assembly errors) the cmdlet throws with a descriptive message.

Security:
- API secrets are converted to `SecureString` and kept in memory only for the duration needed to build the PSCredential.

.LINK
Get-AccessToken
.LINK
Set-TSWorkspace
#>
	[CmdletBinding()]
	param (
		# Defines the source for retrieving the API key
		[Parameter(Mandatory = $true)]
		[ValidateSet("1Password", "Internal", "KeePass")]
		[string]$Source,

		# The name of the 1Password item to fetch
		[Parameter(Mandatory = $true,ParameterSetName = '1Password')]
		[Parameter(Mandatory = $true,ParameterSetName = 'KeePass')]
		[string]
		$APIKeyName,

		# KeePass exe path
		[Parameter(Mandatory = $true,ParameterSetName = 'KeePass')]
		[string]
		$KeePassPath,

		# Path to the keepass db file
		[Parameter(Mandatory = $true,ParameterSetName = 'KeePass')]
		[string]
		$KeePassDB,

		# KeePass password
		[Parameter(Mandatory = $true,ParameterSetName = 'KeePass')]
		[securestring]
		$KeePassPW
	)

	begin {
		# Ensure settings object is initialized
		if (-not $Script:TruesecSettings) {
			throw "Missing `$TruesecSettings. Please reload the Truesec.API module to initialize settings."
		}
	}

	process {
		switch ($Source) {

			"1Password" {
				try {
					# Fetch the API key from 1Password and extract the 'password' field value
					$FromOP = op item get $APIKeyName --format json --reveal | ConvertFrom-Json
					$CredentialObject = [pscredential]::new($($FromOP.fields | Where-Object {$_.label -eq "username"} | Select-Object -ExpandProperty value),$($FromOP.fields | Where-Object {$_.purpose -eq "password"} | Select-Object -ExpandProperty value | ConvertTo-SecureString -AsPlainText -Force))
				}
				catch {
					throw "Failed to retrieve API key from 1Password: $($_.Exception.Message)"
				}
			}
			"KeePass" {
				try {
					[System.Reflection.Assembly]::LoadFrom($KeePassPath) | Out-Null
					[KeePass.Program]::CommonInitialize()

					$ioc = [KeePassLib.Serialization.IOConnectionInfo]::FromPath($KeePassDB)

					$ck = New-Object KeePassLib.Keys.CompositeKey
					$kp = New-Object KeePassLib.Keys.KcpPassword @($([System.Net.NetworkCredential]::new('', $KeePassPW).Password))
					$ck.AddUserKey($kp)

					$pd = New-Object KeePassLib.PwDatabase
					$pd.Open($ioc, $ck, $null)

					$sp = New-Object KeePassLib.SearchParameters
					$sp.SearchString = $APIKeyName

					$pl = New-Object KeePassLib.Collections.PwObjectList[KeePassLib.PwEntry]
					$pd.RootGroup.SearchEntries($sp, $pl)

					# Write-Output "User name of the entry with title '$($sp.SearchString)':"
					$Username = $pl.GetAt(0).Strings.ReadSafe([KeePassLib.PwDefs]::UserNameField)
					$KPPW = $pl.GetAt(0).Strings.ReadSafe([KeePassLib.PwDefs]::PasswordField) | ConvertTo-SecureString -AsPlainText -Force
					
					$CredentialObject = [pscredential]::new($Username, $KPPW)

					$pd.Close()
					Remove-Variable Username, KPPW, pd
					[KeePass.Program]::CommonTerminate()

				}
				catch {
					throw $_.Exception.Message
				}
			}

			"Internal" {
				# Placeholder for future support (e.g., Azure Runbook or secure store)
			}
		}
	}

	end {
		# If the API key was retrieved, store it in the session settings
		if ($CredentialObject) {
			$CredentialObject
		}
	}
}
# End function.