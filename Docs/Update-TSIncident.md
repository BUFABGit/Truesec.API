# Update-TSIncident

## SYNOPSIS
Updates the status and/or comment of a Truesec incident.

## SYNTAX

```
Update-TSIncident [-Id] <String> [[-Status] <String>] [[-Comment] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Update-TSIncident modifies an existing incident by sending a PATCH request to the
Truesec Incident API.
The cmdlet allows updating:
- The **status** of the incident, and/or
- A **comment** describing the update.

The cmdlet requires:
1.
A configured workspace (via Initialize-TSWorkspace).
2.
A valid access token.
If the token is missing or expired,
   it is automatically refreshed using Get-AccessToken.

Once invoked, the function constructs the endpoint URL for the specified incident Id,
creates a JSON body containing the status and/or comment, and submits the update
via an authenticated PATCH request.

## EXAMPLES

### EXAMPLE 1
```powershell
Update-TSIncident -Id "INC-1234" -Status Resolved -Comment "Issue validated and resolved."
# Updates incident INC-1234 by setting its status to Resolved and adding a resolution comment.
```

### EXAMPLE 2
```powershell
Update-TSIncident -Id "INC-5789" -Comment "This 'n that."
# Adds a new comment to the incident without modifying its status.
```

## PARAMETERS

### -Id
The unique identifier of the incident to update.
Mandatory.
Accepts values from pipeline by property name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Status
The new status to assign to the incident.
Must be one of:
- Mitigated
- AcceptedRisk
- Dispensation
- Unresolved
- Resolved
- SecurityTesting
- FalsePositive

This parameter is optional but must not be empty if supplied.

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

### -Comment
A descriptive comment to attach to the updated incident.
Optional but must not be empty if provided.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

### None. This cmdlet does not accept pipeline input except for the Id property via ValueFromPipelineByPropertyName.
## OUTPUTS

### The updated incident object returned by the Truesec API.
### If the update fails, the function writes an error message.
## NOTES
Author: Bufab Global IT, Cybersecurity department  
Workspace configuration is required before running this cmdlet.
 
Access tokens are refreshed automatically when necessary.

Security:
- Authentication is performed using a Bearer token in the Authorization header.

## RELATED LINKS

[Initialize-TSWorkspace]()

[Confirm-NeedNewAccessToken]()

[Get-AccessToken]()