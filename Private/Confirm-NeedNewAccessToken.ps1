function Confirm-NeedNewAccessToken {
<#
.SYNOPSIS
Determines whether a new Truesec API access token is required.

.DESCRIPTION
Confirm-NeedNewAccessToken evaluates the age of the current stored access token and returns a
Boolean value indicating whether a new token should be retrieved.

The function checks:
1. Whether `$TruesecSettings.Session.AccessTokenCreated` exists.
2. If it does, whether more than **4 hours** have passed since token creation.
3. If no timestamp exists, it assumes a new token is required.

The cmdlet does not request or refresh the token itself — it only reports whether a refresh is needed.  
Token renewal is performed by Get-AccessToken.

.INPUTS
None.  
This cmdlet does not accept pipeline input.

.OUTPUTS
System.Boolean  
- **$true**  → A new access token is required.  
- **$false** → The existing token is still valid (less than 4 hours old).

.EXAMPLE
PS> Confirm-NeedNewAccessToken
Returns $true or $false depending on token age.

.EXAMPLE
PS> if (Confirm-NeedNewAccessToken) { Get-AccessToken -APICredentials $Creds }
Checks token freshness and refreshes it if needed.

.NOTES
Author: Bufab Global IT, Cybersecurity department

Behavior:
- If no token creation time exists, the function defaults to requiring a new token.
- Token age is calculated using New-TimeSpan.
- The returned Boolean value is emitted in the end block for easy consumption.

Security:
- This function does not handle credentials or modify token data — it only evaluates timestamps.

.LINK
Get-AccessToken
.LINK
Initialize-TSWorkspace
#>
    [CmdletBinding()]
    
    param ()
    
    begin {
        # Initialization or setup tasks could be added here if needed in the future.
    }
    
    process {
        # Determine if a new access token is needed:
        # If an access token time exists, check if it is older than 4 hours.
        # If no access token time exists, a new token is needed by default.
        $NewAccessToken = if ($TruesecSettings.Session.AccessTokenCreated) {
            # Calculate the timespan since the token's creation
            if ((New-TimeSpan -Start $TruesecSettings.Session.AccessTokenCreated -End $(Get-Date -Format s)).TotalHours -lt 4) {
                # Return false if the token is less than 4 hours old
                $false
            }
            else {
                # Return true if the token is 4 hours old or more
                $true
            }
        }
        else {
            # If no AccessTokenTime is set, default to requiring a new token
            $true
        }
    }
    
    end {
        # Return the final result indicating if a new token is needed
        return $NewAccessToken
    }
}
# End function.
