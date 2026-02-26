function Update-TSThreatEvent {
<#
.SYNOPSIS
Acknowledges a Truesec Threat Event and appends a log message to it.

.DESCRIPTION
Update-TSThreatEvent sends an authenticated PATCH request to the Truesec Threat Event API
to acknowledge a specific threat event and optionally attach a descriptive message.

The cmdlet requires:
1. A configured workspace (via Initialize-TSWorkspace)
2. A valid access token. If missing or expired, it is automatically refreshed through Get-AccessToken.

Once invoked, the cmdlet:
- Builds the endpoint URL using the threat event Id.
- Creates a JSON body containing the log message.
- Sends the update to `<ThreatEventEndpoint>/{Id}/acknowledge`.

A successful update returns the modified Threat Event object.

.PARAMETER Id
The unique identifier of the Threat Event to acknowledge.
Mandatory. Accepts pipeline input by property name.

.PARAMETER Message
A log message describing the reason or context for the acknowledgement.
Optional but must not be empty if provided.

.INPUTS
The Id parameter may be supplied by property name from pipeline input.

.OUTPUTS
The updated Threat Event object returned by the Truesec API.
If the update fails, an error is written and the function returns no output.

.EXAMPLE
PS> Update-TSThreatEvent -Id "TE-10294" -Message "Acknowledged by SOC team."
Acknowledges the specified Threat Event and attaches a log message.

.EXAMPLE
PS> Update-TSThreatEvent -Id "TE-88901"
Acknowledges the Threat Event without adding a comment.

.NOTES
Author: Bufab Global IT, Cybersecurity department
A configured workspace is required before calling this cmdlet.
Access tokens are refreshed automatically when necessary.

Security:
- Authentication is performed using a Bearer token in the Authorization header.

.LINK
Initialize-TSWorkspace
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

		# Comment on the incident
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]
		$Message
	)
	
	begin {
		if (-not ($TruesecSettings.Session.WorkspaceConfigured)) {
			throw "Workspace has not yet been configured. Please run ""Initialize-TSWorkspace"" to properly configure your environment."
		}
		if (Confirm-NeedNewAccessToken) {
			Get-AccessToken -APICredentials $TruesecSettings.Session.ApiCredentials
		}
	}
	
	process {
		$QueryString = "$($TruesecSettings.Endpoints.ThreatEvent)/$Id/acknowledge"
		
		$Body = @{
			logMessage = $Message
		} | ConvertTo-Json

		$InvokeParams = @{
			Uri         = $QueryString
			Body        = $Body
			ContentType = "application/json"
			Header      = @{
				"authorization" = "Bearer $([System.Net.NetworkCredential]::new('', $Script:TruesecSettings.Session.AccessToken).Password)"
			}
			Method      = "Patch"
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