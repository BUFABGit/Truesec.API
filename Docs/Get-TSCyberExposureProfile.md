# Get-TSCyberExposureProfile

## SYNOPSIS
Retrieves one or more Truesec Cyber Exposure Profiles from the configured workspace.

## SYNTAX

### Id
```
Get-TSCyberExposureProfile [-Id <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### All
```
Get-TSCyberExposureProfile [-All] [-PageNumber <Int32>] [-PageSize <Int32>] [-OrderBy <String>]
 [-OrderDirection <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-TSCyberExposureProfile queries the Truesec Cyber Exposure API using the currently configured workspace context.
The cmdlet supports retrieving:
- A specific profile by its **Id**, or
- A collection of profiles using pagination and ordering options.

Before execution, the cmdlet verifies that the workspace has been properly initialized and that a valid access token exists.
If no valid token is found, a new one is automatically acquired.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-TSCyberExposureProfile -Id "abc123"
# Retrieves a single Cyber Exposure Profile with the specified Id.
```

### EXAMPLE 2
```powershell
Get-TSCyberExposureProfile -All -PageNumber 1 -PageSize 25 -OrderBy Rating -OrderDirection Descending
# Retrieves a paged and sorted list of Cyber Exposure Profiles.
```

## PARAMETERS

### -Id
Retrieves a single Cyber Exposure Profile by its unique identifier.
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
Switch indicating that all profiles should be retrieved (paged).
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
Specifies the page number to retrieve when using the **All** parameter set.

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
Defines how many items to include per page when using the **All** parameter set.

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
Specifies which property to sort by.
Valid values are:
- Created  
- Rating  
- CompanyName  
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
Sets the sort order when retrieving multiple profiles.
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

### The Cyber Exposure Profile object(s) returned by the Truesec API.  
### If the API request fails, the cmdlet returns the invocation parameters for troubleshooting.
## NOTES
Author: Bufab Global IT, Cybersecurity department
This cmdlet requires that Initialize-Workspace has been executed before use.
An access token is automatically refreshed if required.

## RELATED LINKS

[Initialize-Workspace]()

[Confirm-NeedNewAccessToken]()

[Get-AccessToken]()

[Get-QueryString]()

