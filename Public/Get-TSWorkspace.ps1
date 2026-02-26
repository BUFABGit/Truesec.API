function Get-TSWorkspace {
<#
.SYNOPSIS
Retrieves information about available Truesec workspaces.

.DESCRIPTION
Get-TSWorkspace queries the Truesec Workspaces API endpoint and returns:
- All available workspaces, or
- A specific workspace when a name is provided via -WorkspaceName.

Before executing the request, the cmdlet ensures a valid access token is available.
If the current token is missing or expired, a new one is automatically acquired using Get-AccessToken.

.PARAMETER WorkspaceName
Specifies the name of a workspace to return.
If omitted, all available workspaces are returned.

.INPUTS
None. This cmdlet does not accept pipeline input.

.OUTPUTS
A workspace object or a collection of workspace objects returned by the Truesec API.

.EXAMPLE
PS> Get-TSWorkspace
Retrieves all available Truesec workspaces for the current session.

.EXAMPLE
PS> Get-TSWorkspace -WorkspaceName "Finance"
Retrieves only the workspace with the name "Finance".

.NOTES
Author: Bufab Global IT, Cybersecurity department
A valid authenticated session is required.
A new access token is automatically retrieved when necessary.

.LINK
Confirm-NeedNewAccessToken
.LINK
Get-AccessToken
.LINK
Initialize-TSWorkspace
#>
    [CmdletBinding()]
    param (
        # Name of the workspace to return
        [Parameter()]
        [string]
        $WorkspaceName
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
			throw $_.Exception.Message
		}
    }
    
    end {
        if ($WorkspaceName) {
            return $($Workspace | Where-Object {$_.name -eq $WorkspaceName})
        }
        else {
            return $Workspace
        }
    }
}
# End function.