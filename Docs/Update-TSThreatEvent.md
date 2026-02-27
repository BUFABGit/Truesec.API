# Update-TSThreatEvent

## SYNOPSIS
Acknowledges a Truesec Threat Event and appends a log message to it.

## SYNTAX

```
Update-TSThreatEvent [-Id] <String> [[-Message] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Update-TSThreatEvent sends an authenticated PATCH request to the Truesec Threat Event API
to acknowledge a specific threat event and optionally attach a descriptive message.

The cmdlet requires:
1.
A configured workspace (via Set-TSWorkspace)
2.
A valid access token.
If missing or expired, it is automatically refreshed through Get-AccessToken.

Once invoked, the cmdlet:
- Builds the endpoint URL using the threat event Id.
- Creates a JSON body containing the log message.
- Sends the update to \`\<ThreatEventEndpoint\>/{Id}/acknowledge\`.

A successful update returns the modified Threat Event object.

## EXAMPLES

### EXAMPLE 1
```powershell
Update-TSThreatEvent -Id "TE-10294" -Message "Acknowledged by SOC team."
# Acknowledges the specified Threat Event and attaches a log message.
```

### EXAMPLE 2
```powershell
Update-TSThreatEvent -Id "TE-88901"
# Acknowledges the Threat Event without adding a comment.
```

## PARAMETERS

### -Id
The unique identifier of the Threat Event to acknowledge.
Mandatory.
Accepts pipeline input by property name.

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

### -Message
A log message describing the reason or context for the acknowledgement.
Optional but must not be empty if provided.

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

### The Id parameter may be supplied by property name from pipeline input.
## OUTPUTS

### The updated Threat Event object returned by the Truesec API.
### If the update fails, an error is written and the function returns no output.
## NOTES
Author: Bufab Global IT, Cybersecurity department
A configured workspace is required before calling this cmdlet.
Access tokens are refreshed automatically when necessary.

Security:
- Authentication is performed using a Bearer token in the Authorization header.

## RELATED LINKS

[Set-TSWorkspace]()

[Confirm-NeedNewAccessToken]()

[Get-AccessToken]()

