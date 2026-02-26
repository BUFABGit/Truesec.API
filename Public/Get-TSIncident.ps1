function Get-TSIncident {
<#
.SYNOPSIS
Retrieves one or more Truesec Incident records from the configured workspace.

.DESCRIPTION
Get-TSIncident queries the Truesec Incident API using the currently configured workspace and active access token.
The cmdlet supports two modes of operation:
- Retrieving a single incident by **Id**, or
- Retrieving multiple incidents using paging, filtering, and ordering options.

Before execution, the cmdlet verifies that the workspace environment is properly initialized via Initialize-TSWorkspace.
If the current session does not have a valid access token, one is automatically acquired.

.PARAMETER Id
Retrieves a single incident by its unique identifier.
Used exclusively in the **Id** parameter set.

.PARAMETER All
Retrieves all incidents using optional pagination and ordering.
Used exclusively in the **All** parameter set.

.PARAMETER Status
Filters the returned incidents by status.
Valid values include:
- Unresolved
- Mitigated
- Dispensation
- AcceptedRisk
- Resolved
- SecurityTesting
- FalsePositive  
Used only in the **All** parameter set.

.PARAMETER PageNumber
Specifies which page to retrieve when using pagination.
Used only in the **All** parameter set.

.PARAMETER PageSize
Specifies how many incident records to return per page.
Defaults to **1000** when -All is used and no PageSize is provided.
Used only in the **All** parameter set.

.PARAMETER OrderBy
Specifies the incident property to sort by. Valid values:
- Created
- LastUpdated
- Severity
- Subject  
Used only in the **All** parameter set.

.PARAMETER OrderDirection
Controls the sorting direction. Valid values:
- Ascending
- Descending  
Used only in the **All** parameter set.

.INPUTS
None. This cmdlet does not accept pipeline input.

.OUTPUTS
One or more Incident objects returned by the Truesec API.
If an error occurs, the cmdlet may return the constructed REST invocation parameters for troubleshooting.

.EXAMPLE
PS> Get-TSIncident -Id "INC-1234"
Retrieves the incident with the specified identifier.

.EXAMPLE
PS> Get-TSIncident -All -Status Unresolved,Mitigated -OrderBy Severity -OrderDirection Descending -PageNumber 1 -PageSize 50
Retrieves a filtered, sorted, and paginated list of incidents from the workspace.

.NOTES
Author: Bufab Global IT, Cybersecurity department  
This cmdlet requires that Initialize-TSWorkspace has been executed beforehand.
Access tokens are automatically refreshed as required.

.LINK
Initialize-TSWorkspace
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
		[Parameter(ParameterSetName = "Id")]
		[string]$Id,
		
		# Retrieve all incidents
		[Parameter(ParameterSetName = "All")]
		[switch]$All,

		# Filter on the status of the incident
		[Parameter(ParameterSetName = "All")]
		[ValidateSet(
			"Unresolved", "Mitigated", "Dispensation", "AcceptedRisk",
			"Resolved", "SecurityTesting", "FalsePositive"
		)]
		[string[]]$Status,

		# Pagenumber for pagination
		[Parameter(ParameterSetName = "All")]
		[int]$PageNumber,

		# Pagesize for pagination
		[Parameter(ParameterSetName = "All")]
		[int]$PageSize,

		# Sort incidents by this property
		[Parameter(ParameterSetName = "All")]
		[ValidateSet("Created", "LastUpdated", "Severity", "Subject")]
		[string]$OrderBy,

		# Sort direction: Ascending or Descending
		[Parameter(ParameterSetName = "All")]
		[ValidateSet("Ascending", "Descending")]
		[string]$OrderDirection
	)
	
	begin {
		# Ensure the workspace is configured
		if (-not ($TruesecSettings.Session.WorkspaceConfigured)) {
			throw "Workspace has not yet been configured. Please run ""Initialize-TSWorkspace"" to properly configure your environment."
		}

		# Acquire a new access token if needed
		if (Confirm-NeedNewAccessToken) {
			Get-AccessToken -APICredentials $TruesecSettings.Session.ApiCredentials
		}

		if ($All -and -not $PageSize) {$PageSize = 1000}
		# Construct the query string from bound parameters
		$QueryString = Get-QueryString -InputParameter $PSBoundParameters -FunctionName $($MyInvocation.MyCommand.Name)
		Write-Verbose ("{0} - line {1}: Constructed querystring: $QueryString" -f $MyInvocation.MyCommand.Name,$MyInvocation.ScriptLineNumber)

	}
	
	process {
		# Prepare REST method call parameters
		$InvokeParams = @{
			Uri         = $QueryString
			Header      = @{
				"authorization" = "Bearer $([System.Net.NetworkCredential]::new('', $Script:TruesecSettings.Session.AccessToken).Password)"
			}
			Method      = "Get"
			ErrorAction = "Stop"
		}

		try {
			# Execute the REST call
			$Result = Invoke-RestMethod @InvokeParams
		}
		catch {
			Write-Error $_.Exception.Message
			# Return invocation parameters for troubleshooting
			$Result = $InvokeParams
		}
	}
	
	end {
		# Return result or fallback output
		if ($Result) {
			return $Result
		} else {
			return $InvokeParams
			Write-Verbose "Failed to retrieve incident(s)."
		}
	}
}
# End function.