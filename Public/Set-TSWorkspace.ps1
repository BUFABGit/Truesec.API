function Set-TSWorkspace {
<#
.SYNOPSIS
Initializes the Truesec workspace context by selecting and configuring a specific workspace.

.DESCRIPTION
Set-TSWorkspace retrieves the list of available workspaces from the Truesec API and configures
the current PowerShell session to use the workspace matching the provided **Id** parameter.

The cmdlet ensures that valid API authentication exists before performing the workspace lookup:
- If the current access token is missing or expired, a new one is acquired via Get-AccessToken.

After retrieving all available workspaces, the cmdlet:
1. Searches for the workspace whose **id** equals the supplied -Id value.
2. If found:
   - Replaces the `{workspaceId}` placeholder in all endpoint URLs inside
     `$Script:TruesecSettings.Endpoints`.
   - Marks the workspace as configured via `$Script:TruesecSettings.Session.WorkspaceConfigured = $true`.
3. If the session is already configured, the cmdlet informs the user and does not reconfigure the endpoints.
4. If the provided Id cannot be found, an error is thrown.

This cmdlet is typically the first step in preparing the environment before calling any other Truesec API cmdlets.

.PARAMETER Id
The unique workspace identifier you want to configure the current session to use.
This value must match an existing workspace returned by the Truesec workspaces endpoint.
Mandatory.

.INPUTS
System.String
You can pipe objects that contain an 'Id' property to Set-TSWorkspace.

.OUTPUTS
None by default.
If successful, updates global Truesec session and endpoint state.
If the workspace cannot be found or retrieved, an exception is thrown.

.EXAMPLE
PS> Set-TSWorkspace -Id "abc123"
Retrieves all workspaces, selects the workspace with id "abc123", injects the id into all endpoint URLs,
and marks the session as configured.

.EXAMPLE
PS> Set-TSWorkspace -Id "prod-primary"
Initializes the session using the workspace whose id matches "prod-primary".
If the workspace is already configured, a message explaining this is returned.

.NOTES
Author: Bufab Global IT, Cybersecurity department

Requirements:
- `$Script:TruesecSettings.Endpoints.Workspaces` must contain the base URI for listing workspaces.
- Endpoint definitions under `$Script:TruesecSettings.Endpoints.*` may contain the `{workspaceId}` placeholder,
  which is replaced during configuration.
- `$Script:TruesecSettings.Session.ApiCredentials` must already be set.
- `$Script:TruesecSettings.Session.AccessToken` must be valid or will be refreshed.

Helper functions expected:
- Confirm-NeedNewAccessToken
- Get-AccessToken
- (Optional) Reset-Workspace for resetting workspace configuration.

Behavior:
- If the provided Id does not match any workspace, the cmdlet throws an error.
- If the workspace is already configured, the cmdlet does not apply configuration again and emits an informational message.

Security:
- Access tokens are inserted into the Authorization header using the Bearer token format.

.LINK
Reset-Workspace
.LINK
Get-AccessToken
.LINK
Confirm-NeedNewAccessToken
.LINK
Get-TSWorkspace
#>
	[CmdletBinding()]
	param (
		# Id of the workspace you want to connect to
		[Parameter(
			Mandatory = $true,
			ValueFromPipelineByPropertyName = $true
		)]
		[string]
		$Id
	)
	
	begin {
		if (Confirm-NeedNewAccessToken) {
			Get-AccessToken -APICredentials $Script:TruesecSettings.Session.ApiCredentials
		}
	}
	
	process {
		$InvokeParams = @{
			Uri    = $($Script:TruesecSettings.Endpoints.Workspaces)
			Header = @{
				"authorization" = "Bearer $([System.Net.NetworkCredential]::new('', $Script:TruesecSettings.Session.AccessToken).Password)"
			}
			ErrorAction = "Stop"
		}

		try {
			$Workspace = Invoke-RestMethod @InvokeParams
		}
		catch {
			Write-Error $_.Exception.Message
		}
	}
	
	end {
		if ($Workspace) {
			$SelectedId = $Workspace | Where-Object {$_.id -eq $Id}
			if (-not $SelectedId) {
				throw "Provided id {$Id} could not be retrieved."
			}
			else {
				if (-not $Script:TruesecSettings.Session.WorkspaceConfigured) {
					$Placeholder = @{
						"{workspaceId}" = "$($Workspace[0].id)"
					}

					$Script:TruesecSettings.Endpoints | ForEach-Object {
						foreach ($Property in $_.PSObject.Properties) {
							if ($Property.Value -match $Placeholder.Keys) {
								$Property.Value = $Property.Value -replace $Placeholder.Keys, $Placeholder.Values
							}
						}
					}

					$Script:TruesecSettings.Session.WorkspaceConfigured = $true
				}
				else {
					Write-Output "Workspace already configured."
					Write-Output "If you want to connect to another workspace, please run ""Reset-Workspace"" first"
				}
			}
		}
		else {
			throw "Failed to retrieve workspaces."
		}
	}
}
# End function.