function Get-QueryString {
<#
.SYNOPSIS
Builds a fully qualified query string for Truesec API requests based on function name and bound parameters.

.DESCRIPTION
Get-QueryString generates the correct API endpoint URL and optional query parameters for all Truesec
“GET” operations.  
It internally selects the correct base endpoint using the calling function name (e.g.,
Get-TSIncident, Get-TSThreatEvent), then formats the URL depending on whether the request is for:

- **A specific resource** (via `Id`)
- **Multiple resources** (via `All` with optional pagination, status filtering, and ordering)

The cmdlet supports:
- Multi-value status filtering, properly formatted as comma-separated values.
- Pagination (`PageNumber`, `PageSize`)
- Ordering (`OrderBy`, optional `OrderDirection`)
- URL encoding of whitespace (converted to `%20`)

It returns the final, fully formatted URL string, ready for Invoke-RestMethod.

.PARAMETER InputParameter
A hashtable containing the bound parameters from the calling function  
(e.g. `$PSBoundParameters`).  
Expected keys may include: Id, All, Status, PageNumber, PageSize, OrderBy, OrderDirection.

.PARAMETER FunctionName
The name of the calling function, used to determine the correct base API endpoint.  
Examples:
- "Get-TSIncident"
- "Get-TSThreatEvent"
- "Get-TSCyberExposureProfile"
- Any "*-TSWorkspace" name

.INPUTS
None.  
The cmdlet does not accept pipeline input.

.OUTPUTS
System.String  
A fully constructed query string URL suitable for REST API requests.

.EXAMPLE
PS> Get-QueryString -InputParameter @{ Id = "INC-123" } -FunctionName "Get-TSIncident"
Returns a URL such as:
https://api.example.com/incidents/INC-123

.EXAMPLE
PS> Get-QueryString -InputParameter @{ All = $true; PageNumber = 1; PageSize = 50 } -FunctionName "Get-TSCyberExposureProfile"
Returns a URL with pagination parameters.

.EXAMPLE
PS> Get-QueryString -InputParameter @{ All = $true; Status = @("Unresolved","Mitigated"); OrderBy = "Created"; OrderDirection = "Descending" } -FunctionName "Get-TSIncident"
Builds a properly formatted query string with multi-value status and descending sort order.

.NOTES
Author: Bufab Global IT, Cybersecurity department

Behavior:
- Base endpoint selection is determined by wildcard matching the FunctionName.
- Multi-value Status fields are expanded into a comma-separated query parameter.
- OrderDirection is mapped to "asc" or "desc".
- Whitespace is URL‑encoded as `%20`.
- For “Id” mode, the function simply appends `/<Id>` to the base URL.
- For “All” mode, property order is preserved, and each property becomes:  
  `?key=value` followed by `&key=value`.

Security:
- This cmdlet performs only URL construction; it does not send API requests and handles no secrets.

.LINK
Get-TSCyberExposureProfile
.LINK
Get-TSIncident
.LINK
Get-TSThreatEvent
.LINK
Initialize-TSWorkspace
#>
	[CmdletBinding()]
	param (
		[Parameter()]
		[System.Object]
		$InputParameter,

		[Parameter()]
		[string]
		$FunctionName
	)
	
	begin {
		$BaseUrl = switch -Wildcard ($FunctionName) {
			"Get-TSCyberExposureProfile" {$TruesecSettings.Endpoints.CyberExposureProfiles}
			"Get-TSIncident" 		 	 {$TruesecSettings.Endpoints.Incidents}
			"Get-TSVulnerability"		 {$TruesecSettings.Endpoints.Vulnerability}
			"*-TSWorkspace"				 {$TruesecSettings.Endpoints.Workspaces}
			"Get-TSThreatEvent"			 {$TruesecSettings.Endpoints.ThreatEvent}
		}
	}
	
	process {
		$QueryString = switch ($InputParameter.Keys) {
			Id {
				"$($BaseUrl)/$Id"
			}
			All {
				$Properties = switch ($InputParameter.Keys) {
					Status {
						if ($Status.Count -gt 1) {
							[string]$StatusFormatted = ""
							$Counter = 0
							$Max = $Status.Count
							foreach ($Property in $Status) {
								$Counter++
								if ($Counter -eq 1) {
									$StatusFormatted += "Status=$($Property),"
								}
								elseif ($Counter -ne $Max) {
									$StatusFormatted += "$($Property),"
								}
								else {
									$StatusFormatted += $Property
								}
							}
							$StatusFormatted
						}
						else {
							"Status=$($Status)"
						}
					}
					PageNumber {"PageNumber=$PageNumber"}
					PageSize {"PageSize=$PageSize"}
					OrderBy {
						if ($OrderDirection) {
							switch ($OrderDirection) {
								Ascending {$Direction = "asc"}
								Descending {$Direction = "desc"}
							}
							"OrderBy=$($OrderBy) $($Direction)"
						}
						else {
							"OrderBy=$OrderBy asc"
						}
					}
				}
				
				$Counter = 0
				[string]$QueryProperties = ""
				foreach ($QString in $Properties) {
					$Counter++
					if ($QString -match '\s*$') {
						$QString = $QString.Replace(" ", "%20")
					}
					if ($Counter -eq 1) {
						$QueryProperties += "?$QString"
					}
					else {
						$QueryProperties += "&$QString"
					}
				}

				$BaseUrl + $QueryProperties
			}
		}
	}
	
	end {
		return $QueryString
	}
}
# End function.