# Get-QueryString

## SYNOPSIS
Builds a fully qualified query string for Truesec API requests based on function name and bound parameters.

## SYNTAX

```
Get-QueryString [[-InputParameter] <Object>] [[-FunctionName] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Get-QueryString generates the correct API endpoint URL and optional query parameters for all Truesec
"GET" operations.
 
It internally selects the correct base endpoint using the calling function name (e.g.,
Get-TSIncident, Get-TSThreatEvent), then formats the URL depending on whether the request is for:

- **A specific resource** (via \`Id\`)
- **Multiple resources** (via \`All\` with optional pagination, status filtering, and ordering)

The cmdlet supports:
- Multi-value status filtering, properly formatted as comma-separated values.
- Pagination (\`PageNumber\`, \`PageSize\`)
- Ordering (\`OrderBy\`, optional \`OrderDirection\`)
- URL encoding of whitespace (converted to \`%20\`)

It returns the final, fully formatted URL string, ready for Invoke-RestMethod.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-QueryString -InputParameter @{ Id = "INC-123" } -FunctionName "Get-TSIncident"
# Returns a URL such as: https://api.example.com/incidents/INC-123
```

### EXAMPLE 2
```powershell
Get-QueryString -InputParameter @{ All = $true; PageNumber = 1; PageSize = 50 } -FunctionName "Get-TSCyberExposureProfile"
# Returns a URL with pagination parameters.
```

### EXAMPLE 3
```powershell
Get-QueryString -InputParameter @{ All = $true; Status = @("Unresolved","Mitigated"); OrderBy = "Created"; OrderDirection = "Descending" } -FunctionName "Get-TSIncident"
# Builds a properly formatted query string with multi-value status and descending sort order.
```

## PARAMETERS

### -InputParameter
A hashtable containing the bound parameters from the calling function
(e.g.
\`$PSBoundParameters\`).

Expected keys may include: Id, All, Status, PageNumber, PageSize, OrderBy, OrderDirection.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FunctionName
The name of the calling function, used to determine the correct base API endpoint.
 
Examples:
- "Get-TSIncident"
- "Get-TSThreatEvent"
- "Get-TSCyberExposureProfile"
- Any "*-TSWorkspace" name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.  
### The cmdlet does not accept pipeline input.
## OUTPUTS

### System.String  
### A fully constructed query string URL suitable for REST API requests.
## NOTES
Author: Bufab Global IT, Cybersecurity department

Behavior:
- Base endpoint selection is determined by wildcard matching the FunctionName.
- Multi-value Status fields are expanded into a comma-separated query parameter.
- OrderDirection is mapped to "asc" or "desc".
- Whitespace is URL-encoded as \`%20\`.
- For "Id" mode, the function simply appends \`/\<Id\>\` to the base URL.
- For "All" mode, property order is preserved, and each property becomes:  
  \`?key=value\` followed by \`&key=value\`.

Security:
- This cmdlet performs only URL construction; it does not send API requests and handles no secrets.

## RELATED LINKS

[Get-TSCyberExposureProfile](Get-TSCyberExposureProfile.md)

[Get-TSIncident](Get-TSIncident.md)

[Get-TSThreatEvent](Get-TSThreatEvent.md)

[Set-TSWorkspace](Set-TSWorkspace.md)