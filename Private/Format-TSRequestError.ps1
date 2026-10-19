function Format-TSRequestError {
<#
.SYNOPSIS
Builds a safe, one-line error message for a failed Truesec API request.
.DESCRIPTION
Format-TSRequestError turns the error record of a failed Invoke-RestMethod call into a message with the method, the
request path (no query string), the HTTP status and the API's own error text.
It never includes request headers, so the bearer token cannot end up in error output or in logs; anything that looks
like a bearer token in the API's text is masked as well.
.PARAMETER ErrorRecord
The error record caught from Invoke-RestMethod ($_ in a catch block).
.PARAMETER Method
The HTTP method of the request. Defaults to GET.
.PARAMETER Uri
The request URI. Only its path is used.
.OUTPUTS
System.String
.EXAMPLE
PS> try { Invoke-RestMethod @InvokeParams } catch { throw (Format-TSRequestError -ErrorRecord $_ -Method Get -Uri $InvokeParams.Uri) }
Throws "Truesec API request failed: GET /workspaces/<id>/incidents (HTTP 404). ..." without the Authorization header.
.NOTES
Author: Bufab Global IT, Cybersecurity department
#>
	[CmdletBinding()]
	[OutputType([string])]
	param (
		[Parameter(Mandatory = $true)]
		[System.Management.Automation.ErrorRecord]
		$ErrorRecord,
		[Parameter()]
		[string]
		$Method = 'Get',
		[Parameter()]
		[string]
		$Uri
	)
	$Path = ''
	if ($Uri) {
		try { $Path = ([uri]$Uri).AbsolutePath } catch { $Path = ($Uri -split '\?')[0] }
	}
	$Status = $null
	try { $Status = [int]$ErrorRecord.Exception.Response.StatusCode } catch { $Status = $null }
	$Detail = $null
	if ($ErrorRecord.ErrorDetails -and $ErrorRecord.ErrorDetails.Message) {
		$Detail = $ErrorRecord.ErrorDetails.Message
		try {
			$Json = $Detail | ConvertFrom-Json -ErrorAction Stop
			foreach ($Name in 'error_description', 'message', 'title', 'error') {
				if ($Json.PSObject.Properties[$Name] -and $Json.$Name -is [string]) { $Detail = $Json.$Name; break }
			}
		}
		catch {
			Write-Verbose 'Error body is not JSON; using it as text.'
		}
	}
	if (-not $Detail) { $Detail = $ErrorRecord.Exception.Message }
	$Detail = ([string]$Detail -replace '(?i)bearer\s+[A-Za-z0-9\-\._~\+/]+=*', 'Bearer ***').Split("`n")[0].Trim()
	if ($Detail.Length -gt 300) { $Detail = $Detail.Substring(0, 300) }
	$StatusText = if ($Status) { " (HTTP $Status)" } else { '' }
	return "Truesec API request failed: $($Method.ToUpper()) $Path$StatusText. $Detail".Trim()
}
# End function.
