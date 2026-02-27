# Get-TSThreatEvent

## SYNOPSIS
Retrieves one or more Truesec Threat Events from the configured workspace.

## SYNTAX

### Id
```
Get-TSThreatEvent [-Id <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### All
```
Get-TSThreatEvent [-All] [-PageNumber <Int32>] [-PageSize <Int32>] [-OrderBy <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-TSThreatEvent queries the Truesec Threat Event API and returns either:
- A single threat event specified by **Id**, or
- A collection of threat events using pagination and sorting options.

Before execution, the cmdlet ensures that:
1.
The workspace has been initialized via Set-TSWorkspace.
2.
A valid access token exists, refreshing it automatically if required.

When retrieving all threat events using the **All** parameter set, the cmdlet supports pagination and sorting.
If -All is used without a PageSize, the default PageSize becomes **1000**.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-TSThreatEvent -Id "TEV-9001"
# Retrieves a single Threat Event using its unique identifier.
```

### EXAMPLE 2
```powershell
Get-TSThreatEvent -All -PageNumber 1 -PageSize 100 -OrderBy Created
# Retrieves a paginated, sorted list of Threat Events.
```

## PARAMETERS

### -Id
Retrieves a single Threat Event by its unique identifier.
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
Retrieves all threat events using optional pagination and sorting.
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

### -PageNumber
Specifies which page of results to retrieve when using pagination.
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
Specifies how many threat events to return per page.
Defaults to **1000** when -All is specified without PageSize.
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
Specifies the property to sort on.
Valid values:
- Created
- LastUpdated
- Id  
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

### A Threat Event object or a collection of Threat Event objects returned by the Truesec API.
### If an error occurs, the cmdlet returns the REST invocation parameters to assist with troubleshooting.
## NOTES
Author: Bufab Global IT, Cybersecurity department
Requires a configured workspace (Set-TSWorkspace).
Access tokens are automatically refreshed when needed.

## RELATED LINKS

[Set-TSWorkspace]()

[Confirm-NeedNewAccessToken]()

[Get-AccessToken]()

[Get-QueryString]()

