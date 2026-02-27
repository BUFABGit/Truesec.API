function Get-TSThreatEvent {
<#
.SYNOPSIS
Retrieves one or more Truesec Threat Events from the configured workspace.

.DESCRIPTION
Get-TSThreatEvent queries the Truesec Threat Event API and returns either:
- A single threat event specified by **Id**, or
- A collection of threat events using pagination and sorting options.

Before execution, the cmdlet ensures that:
1. The workspace has been initialized via Set-TSWorkspace.
2. A valid access token exists, refreshing it automatically if required.

When retrieving all threat events using the **All** parameter set, the cmdlet supports pagination and sorting.
If -All is used without a PageSize, the default PageSize becomes **1000**.

.PARAMETER Id
Retrieves a single Threat Event by its unique identifier.
Used exclusively in the **Id** parameter set.

.PARAMETER All
Retrieves all threat events using optional pagination and sorting.
Used exclusively in the **All** parameter set.

.PARAMETER PageNumber
Specifies which page of results to retrieve when using pagination.
Used only in the **All** parameter set.

.PARAMETER PageSize
Specifies how many threat events to return per page.
Defaults to **1000** when -All is specified without PageSize.
Used only in the **All** parameter set.

.PARAMETER OrderBy
Specifies the property to sort on. Valid values:
- Created
- LastUpdated
- Id  
Used only in the **All** parameter set.

.INPUTS
None. This cmdlet does not accept pipeline input.

.OUTPUTS
A Threat Event object or a collection of Threat Event objects returned by the Truesec API.
If an error occurs, the cmdlet returns the REST invocation parameters to assist with troubleshooting.

.EXAMPLE
PS> Get-TSThreatEvent -Id "TEV-9001"
Retrieves a single Threat Event using its unique identifier.

.EXAMPLE
PS> Get-TSThreatEvent -All -PageNumber 1 -PageSize 100 -OrderBy Created
Retrieves a paginated, sorted list of Threat Events.

.NOTES
Author: Bufab Global IT, Cybersecurity department
Requires a configured workspace (Set-TSWorkspace).
Access tokens are automatically refreshed when needed.

.LINK
Set-TSWorkspace
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

		# Pagenumber for pagination
		[Parameter(ParameterSetName = "All")]
		[int]$PageNumber,

		# Pagesize for pagination
		[Parameter(ParameterSetName = "All")]
		[int]$PageSize,

		# Sort incidents by this property
		[Parameter(ParameterSetName = "All")]
		[ValidateSet("Created", "LastUpdated", "Id")]
		[string]$OrderBy
	)
    
    begin {
        # Ensure the workspace is configured
		if (-not ($TruesecSettings.Session.WorkspaceConfigured)) {
			throw "Workspace has not yet been configured. Please run ""Set-TSWorkspace"" to properly configure your environment."
		}

		# Acquire a new access token if needed
		if (Confirm-NeedNewAccessToken) {
			Get-AccessToken -APICredentials $TruesecSettings.Session.ApiCredentials
		}
		
		if ($All -and -not $PageSize) {$PageSize = 1000}
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
			Write-Output "Failed to retrieve incident(s)."
		}
    }
}
# End function.