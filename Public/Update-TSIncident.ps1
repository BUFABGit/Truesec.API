function Update-TSIncident {
<#
.SYNOPSIS
Updates the status and/or comment of a Truesec incident.

.DESCRIPTION
Update-TSIncident modifies an existing incident by sending a PATCH request to the
Truesec Incident API. The cmdlet allows updating:
- The **status** of the incident, and/or
- A **comment** describing the update.

The cmdlet requires:
1. A configured workspace (via Set-TSWorkspace).
2. A valid access token. If the token is missing or expired,
   it is automatically refreshed using Get-AccessToken.

Once invoked, the function constructs the endpoint URL for the specified incident Id,
creates a JSON body containing the status and/or comment, and submits the update
via an authenticated PATCH request.

.PARAMETER Id
The unique identifier of the incident to update.
Mandatory. Accepts values from pipeline by property name.

.PARAMETER Status
The new status to assign to the incident.
Must be one of:
- Mitigated
- AcceptedRisk
- Dispensation
- Unresolved
- Resolved
- SecurityTesting
- FalsePositive

This parameter is optional but must not be empty if supplied.

.PARAMETER Comment
A descriptive comment to attach to the updated incident.
Optional but must not be empty if provided.

.INPUTS
None. This cmdlet does not accept pipeline input except for the Id property via ValueFromPipelineByPropertyName.

.OUTPUTS
The updated incident object returned by the Truesec API.
If the update fails, the function writes an error message.

.EXAMPLE
PS> Update-TSIncident -Id "INC-1234" -Status Resolved -Comment "Issue validated and resolved."
Updates incident INC-1234 by setting its status to Resolved and adding a resolution comment.

.EXAMPLE
PS> Update-TSIncident -Id "INC-5789" -Comment "Additional details provided."
Adds a new comment to the incident without modifying its status.

.NOTES
Author: Bufab Global IT, Cybersecurity department  
Workspace configuration is required before running this cmdlet.  
Access tokens are refreshed automatically when necessary.

Security:
- Authentication is performed using a Bearer token in the Authorization header.

.LINK
Set-TSWorkspace
.LINK
Confirm-NeedNewAccessToken
.LINK
Get-AccessToken
#>
	[CmdletBinding()]
	param (
		# Id of the incident that will be updated.
		[Parameter(
			Mandatory = $true,
			ValueFromPipelineByPropertyName = $true
		)]
		[string]
		$Id,

		# Parameter help description
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[ValidateSet(
			"Mitigated",
			"AcceptedRisk",
			"Dispensation",
			"Unresolved",
			"Resolved",
			"SecurityTesting",
			"FalsePositive"
		)]
		[string]
		$Status,

		# Comment on the incident
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]
		$Comment
	)
	
	begin {
		if (-not ($TruesecSettings.Session.WorkspaceConfigured)) {
			throw "Workspace has not yet been configured. Please run ""Set-TSWorkspace"" to properly configure your environment."
		}
		if (Confirm-NeedNewAccessToken) {
			Get-AccessToken -APICredentials $TruesecSettings.Session.ApiCredentials
		}
	}
	
	process {
		$QueryString = "$($TruesecSettings.Endpoints.Incidents)/$Id"
		
		$Body = @{
			status = $Status
			comment = $Comment
		} | ConvertTo-Json

		$InvokeParams = @{
			Uri    = $QueryString
			Body = $Body
			ContentType = "application/json"
			Header = @{
				"authorization" = "Bearer $([System.Net.NetworkCredential]::new('', $Script:TruesecSettings.Session.AccessToken).Password)"
			}
			Method = "Patch"
			ErrorAction = "Stop"
		}

		try {
			$Result = Invoke-RestMethod @InvokeParams
		}
		catch {
			Write-Error $_.Exception.Message
		}
	}
	
	end {
		if ($Result) {
			return $Result
		}
		<# For debugging
		else {
			return $InvokeParams
		}
        #>
	}
}
# End function.