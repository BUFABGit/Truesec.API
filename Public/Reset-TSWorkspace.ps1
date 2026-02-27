function Reset-TSWorkspace {
<#
.SYNOPSIS
Resets the configured Truesec workspace and restores the original workspace settings file.

.DESCRIPTION
Reset-TSWorkspace clears the currently configured Truesec workspace state and reloads the
original workspace configuration from disk.  
This is typically used when switching to another workspace or when the session has become
misconfigured.

The cmdlet performs the following steps:
1. Verifies that a workspace has been configured. If not, the cmdlet stops with an error.
2. Ensures a valid access token exists, refreshing it if required.
3. Prompts the user for confirmation before making any changes.
4. If the user confirms:
   - Clears the global `$TruesecSettings` variable.
   - Reloads the settings JSON file from the path stored in `$TruesecSettings.SettingsPath`.
   - Re‑attaches the SettingsPath property to the newly loaded object.
5. If the user declines:
   - Aborts the operation and writes a cancellation message.

Resetting the workspace does **not** remove stored API credentials, but it does require the
session to reinitialize the workspace using Set-TSWorkspace.

.INPUTS
None. This cmdlet does not accept pipeline input.

.OUTPUTS
None.  
Writes confirmation or cancellation messages to the pipeline.

.EXAMPLE
PS> Reset-TSWorkspace
Prompts the user for confirmation and, if confirmed, resets the workspace configuration.

.EXAMPLE
PS> Reset-TSWorkspace -Verbose
Runs the reset process and shows verbose diagnostic output as applicable.

.NOTES
Author: Bufab Global IT, Cybersecurity department  
A workspace must have been previously configured before this cmdlet can be used.

Helper functions used:
- Confirm-NeedNewAccessToken
- Get-AccessToken

Security:
- Access tokens are handled using the standard Bearer authorization header format.

.LINK
Set-TSWorkspace
.LINK
Confirm-NeedNewAccessToken
.LINK
Get-AccessToken
#>
	[CmdletBinding()]
	param (
		
	)
	
	begin {
		if (-not ($TruesecSettings.Session.WorkspaceConfigured)) {
			throw "Workspace has not been configured yet, no need to reset."
		}
		if (Confirm-NeedNewAccessToken) {
			Get-AccessToken -APICredentials $TruesecSettings.Session.ApiCredentials
		}
	}

	process {
		while ($Answer -notin @("y", "n")) {
			$Answer = Read-Host -Prompt "Are you sure you want to reset the configured Workspace?`nIf an active access token is present, a new one will need to be retrieved.`n(y/n)"
			if ($Answer -notin @("y", "n")) {
				Write-Warning "Invalid input. Please enter 'y' for yes or 'n' for no."
			}
		}

		if ($Answer -eq "y") {
			try {
				$SettingsPath = $TruesecSettings.SettingsPath
				Clear-Variable -Name TruesecSettings -Scope Global -Force -ErrorAction Stop
				$Global:TruesecSettings = Get-Content -Path $SettingsPath | ConvertFrom-Json
				$Global:TruesecSettings | Add-Member -MemberType NoteProperty -Name SettingsPath -Value $SettingsPath
			}
			catch {
				Write-Error $_.Exception.Message
			}
		}
		else {
			Write-Output "Operation canceled by user input."
			return
		}
	}

	end {
		
	}
}
# End function.