# Get-TSIncident

## SYNOPSIS
Retrieves one or more Truesec Incident records from the configured workspace.

## SYNTAX

### Id
```
Get-TSIncident [-Id <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### All
```
Get-TSIncident [-All] [-Status <String[]>] [-PageNumber <Int32>] [-PageSize <Int32>] [-OrderBy <String>]
 [-OrderDirection <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-TSIncident queries the Truesec Incident API using the currently configured workspace and active access token.
The cmdlet supports two modes of operation:
- Retrieving a single incident by **Id**, or
- Retrieving multiple incidents using paging, filtering, and ordering options.

Before execution, the cmdlet verifies that the workspace environment is properly initialized via Initialize-TSWorkspace.
If the current session does not have a valid access token, one is automatically acquired.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-TSIncident -Id "INC-1234"
# Retrieves the incident with the specified identifier.
```

### EXAMPLE 2
```powershell
Get-TSIncident -All -Status Unresolved,Mitigated -OrderBy Severity -OrderDirection Descending -PageNumber 1 -PageSize 50
# Retrieves a filtered, sorted, and paginated list of incidents from the workspace.
```

## PARAMETERS

### -Id
Retrieves a single incident by its unique identifier.
Used exclusively in the **Id** parameter set.

```yaml
Type: String
Parameter Sets: Id
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Retrieves all incidents using optional pagination and ordering.
Used exclusively in the **All** parameter set.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
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

```yaml
Type: String[]
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageNumber
Specifies which page to retrieve when using pagination.
Used only in the **All** parameter set.

```yaml
Type: Int32
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize
Specifies how many incident records to return per page.
Defaults to **1000** when -All is used and no PageSize is provided.
Used only in the **All** parameter set.

```yaml
Type: Int32
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrderBy
Specifies the incident property to sort by.
Valid values:
- Created
- LastUpdated
- Severity
- Subject  
Used only in the **All** parameter set.

```yaml
Type: String
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrderDirection
Controls the sorting direction.
Valid values:
- Ascending
- Descending  
Used only in the **All** parameter set.

```yaml
Type: String
Parameter Sets: All
Aliases:

Required: False
Position: Named
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

### None. This cmdlet does not accept pipeline input.
## OUTPUTS

### One or more Incident objects returned by the Truesec API.
### If an error occurs, the cmdlet may return the constructed REST invocation parameters for troubleshooting.
## NOTES
Author: Bufab Global IT, Cybersecurity department  
This cmdlet requires that Initialize-TSWorkspace has been executed beforehand.
Access tokens are automatically refreshed as required.

## RELATED LINKS

[Initialize-TSWorkspace]()

[Confirm-NeedNewAccessToken]()

[Get-AccessToken]()

[Get-QueryString]()

