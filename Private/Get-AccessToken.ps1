function Get-AccessToken {
<#
.SYNOPSIS
Retrieves or refreshes the Truesec API access token used for authentication.

.DESCRIPTION
Get-AccessToken requests a new access token from the Truesec authentication endpoint
when the existing token is missing or expired.  
Token freshness is evaluated by Confirm-NeedNewAccessToken, which checks whether the
current token is older than 4 hours.

When a refresh is required, the cmdlet:
1. Constructs the JSON request body using:
   - The BaseAppUri (audience)
   - The client_id (API username)
   - The client_secret (API key)
2. Sends an authenticated POST request to the AuthUri endpoint.
3. Stores the resulting token (as a SecureString) in:
   - `$Script:TruesecSettings.Session.AccessToken`
   - `$Script:TruesecSettings.Session.AccessTokenCreated`

If the token is still valid, the cmdlet writes “Current token still active.”

.PARAMETER ApiCredentials
(Optional) A PSCredential object containing the API client_id and client_secret.
If omitted, the function uses `$Script:TruesecSettings.Session.ApiCredentials`.

.INPUTS
None.  
This cmdlet does not accept pipeline input.

.OUTPUTS
None directly.  
On success, the function **updates global session state** with a new token.  
If the token request fails, an exception is thrown.

.EXAMPLE
PS> Get-AccessToken -ApiCredentials (Get-Credential)
Requests a new access token using the supplied PSCredential and stores it in session
configuration.

.EXAMPLE
PS> Get-AccessToken
Uses previously stored API credentials to refresh the access token if required.

.NOTES
Author: Bufab Global IT, Cybersecurity department

Behavior:
- Tokens older than 4 hours automatically trigger a refresh.
- Newly retrieved tokens are stored as SecureString values.
- Timestamp is recorded in ISO-like "yyyy-MM-ddTHH:mm:ss" format.

Security:
- Authentication uses the client_credentials OAuth2 flow.
- Sensitive values (client_secret, access_token) are kept as SecureStrings in memory.

Related configuration fields:
- `$Script:TruesecSettings.Endpoints.AuthUri`
- `$Script:TruesecSettings.Endpoints.BaseAppUri`
- `$Script:TruesecSettings.Session.ApiCredentials`

.LINK
Confirm-NeedNewAccessToken
.LINK
Set-TSWorkspace
#>
	[CmdletBinding()]
	param (
		# Credential object for API authentication
		[Parameter()]
		[System.Management.Automation.PSCredential]
		$ApiCredentials
	)
	
	begin {
		# Check if a new access token is needed
		$RefreshToken = Confirm-NeedNewAccessToken
	}
	
	process {
		if ($RefreshToken) {
			# Prepare the API request body with required parameters
			$APIBody = @{
				audience      = $Script:TruesecSettings.Endpoints.BaseAppUri
				grant_type    = "client_credentials"
				client_id     = $Script:TruesecSettings.Session.ApiCredentials.UserName
				client_secret = $Script:TruesecSettings.Session.ApiCredentials.GetNetworkCredential().Password
			} | ConvertTo-Json
	
			# Set the request headers for JSON content type
			$Header = @{
				"content-type" = "application/json"
			}
	
			# Configure parameters for the Invoke-RestMethod call
			$InvokeParams = @{
				Method	 	= "Post"
				Uri 		= $Script:TruesecSettings.Endpoints.AuthUri
				Body 		= $APIBody
				Headers 	= $Header
				ErrorAction = "Stop"
			}

			try {
				# Send the request and retrieve the access token
				$AccessToken = Invoke-RestMethod @InvokeParams | Select-Object -ExpandProperty access_token | ConvertTo-SecureString -AsPlainText -Force
				$TimeStamp = $(Get-Date -Format s)
				$ResponseOK = $true
			}
			catch {
				# Handle errors during the request
				Write-Error $_.Exception.Message
				$ResponseOK = $false
			}
		}
	}
	
	end {
		# Update token and timestamp in settings if a new token was generated successfully
		if ($RefreshToken) {
			switch ($ResponseOK) {
				True  {
					# Store the new token and timestamp in settings
					if (-not ($TruesecSettings.Session.AccessToken)) {
						$Script:TruesecSettings.Session.AccessToken = $AccessToken
					}
					else {
						$Script:TruesecSettings.Session.AccessToken = $AccessToken
					}

					if (-not ($Script:TruesecSettings.Session.AccessTokenCreated)) {
						$Script:TruesecSettings.Session.AccessTokenCreated = $TimeStamp
					}
					else {
						$Script:TruesecSettings.Session.AccessTokenCreated = $TimeStamp
					}
				}
				False {
					throw $Error[0]
				}
			}
		}
		else {
			# Output if the current token is still valid
			Write-Output "Current token still active."
		}
	}
}
# End function.