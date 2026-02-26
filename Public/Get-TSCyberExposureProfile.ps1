function Get-TSCyberExposureProfile {
<#
.SYNOPSIS
Retrieves one or more Truesec Cyber Exposure Profiles from the configured workspace.

.DESCRIPTION
Get-TSCyberExposureProfile queries the Truesec Cyber Exposure API using the currently configured workspace context.
The cmdlet supports retrieving:
- A specific profile by its **Id**, or
- A collection of profiles using pagination and ordering options.

Before execution, the cmdlet verifies that the workspace has been properly initialized and that a valid access token exists.
If no valid token is found, a new one is automatically acquired.

.PARAMETER Id
Retrieves a single Cyber Exposure Profile by its unique identifier.
Used exclusively in the **Id** parameter set.

.PARAMETER All
Switch indicating that all profiles should be retrieved (paged).
Used exclusively in the **All** parameter set.

.PARAMETER PageNumber
Specifies the page number to retrieve when using the **All** parameter set.

.PARAMETER PageSize
Defines how many items to include per page when using the **All** parameter set.

.PARAMETER OrderBy
Specifies which property to sort by. Valid values are:
- Created  
- Rating  
- CompanyName  
Used only in the **All** parameter set.

.PARAMETER OrderDirection
Sets the sort order when retrieving multiple profiles. Valid values:
- Ascending
- Descending  
Used only in the **All** parameter set.

.INPUTS
None. This cmdlet does not accept pipeline input.

.OUTPUTS
The Cyber Exposure Profile object(s) returned by the Truesec API.  
If the API request fails, the cmdlet returns the invocation parameters for troubleshooting.

.EXAMPLE
PS> Get-TSCyberExposureProfile -Id "abc123"
Retrieves a single Cyber Exposure Profile with the specified Id.

.EXAMPLE
PS> Get-TSCyberExposureProfile -All -PageNumber 1 -PageSize 25 -OrderBy Rating -OrderDirection Descending
Retrieves a paged and sorted list of Cyber Exposure Profiles.

.NOTES
Author: Bufab Global IT, Cybersecurity department
This cmdlet requires that Initialize-Workspace has been executed before use.
An access token is automatically refreshed if required.

.LINK
Initialize-Workspace
.LINK
Confirm-NeedNewAccessToken
.LINK
Get-AccessToken
.LINK
Get-QueryString
#>
	[CmdletBinding()]

	param (
		# Incident id
		[Parameter(
			ParameterSetName = "Id"
		)]
		[string]
		$Id,
		
		# All incidents
		[Parameter(
			ParameterSetName = "All"
		)]
		[switch]
		$All,

		# Pagenumber
		[Parameter(
			ParameterSetName = "All"
		)]
		[int]
		$PageNumber,

		# Pagesize
		[Parameter(
			ParameterSetName = "All"
		)]
		[int]
		$PageSize,

		# Order by property
		[Parameter(
			ParameterSetName = "All"
		)]
		[ValidateSet(
			"Created",
			"Rating",
			"CompanyName"
		)]
		[string]
		$OrderBy,

		# Order direction
		[Parameter(
			ParameterSetName = "All"
		)]
		[ValidateSet(
			"Ascending",
			"Descending"
		)]
		[string]
		$OrderDirection
	)
	
	begin {
		if (-not ($TruesecSettings.Session.WorkspaceConfigured)) {
			throw "Workspace has not yet been configured. Please run ""Initialize-TSWorkspace"" to properly configure your environment."
		}
		# Check to see if there exists an active access token.
		if (Confirm-NeedNewAccessToken) {
			Get-AccessToken -APICredentials $APICredentials
		}
		
		$QueryString = Get-QueryString -InputParameter $PSBoundParameters -FunctionName $($MyInvocation.MyCommand.Name)
		Write-Verbose ("{0} - line {1}: Constructed querystring: $QueryString" -f $MyInvocation.MyCommand.Name,$MyInvocation.ScriptLineNumber)
	}
	
	process {
		$InvokeParams = @{
			Uri    = $QueryString
			Header = @{
				"authorization" = "Bearer $([System.Net.NetworkCredential]::new('', $Script:TruesecSettings.Session.AccessToken).Password)"
			}
			Method = "Get"
			ErrorAction = "Stop"
		}

		try {
			$Result = Invoke-RestMethod @InvokeParams
		}
		catch {
			Write-Error $_.Exception.Message
			<# Debugging
			$Result = $InvokeParams
			#>
		}
	}
	
	end {
		# return $InvokeParams
		if ($Result) {
			return $Result
		}
		else {
			return $InvokeParams
			Write-Output "Failed to retrieve incident(s)."
		}
	}
}
# End function.