# Set-TSWorkspace

## SYNOPSIS
Initializes the Truesec workspace context by selecting and configuring a specific workspace.

## SYNTAX

```
Set-TSWorkspace [-Id] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Set-TSWorkspace retrieves the list of available workspaces from the Truesec API and configures
the current PowerShell session to use the workspace matching the provided **Id** parameter.

The cmdlet ensures that valid API authentication exists before performing the workspace lookup:
- If the current access token is missing or expired, a new one is acquired via Get-AccessToken.

After retrieving all available workspaces, the cmdlet:
1.
Searches for the workspace whose **id** equals the supplied -Id value.
2.
If found:
   - Replaces the \`{workspaceId}\` placeholder in all endpoint URLs inside
     \`$Script:TruesecSettings.Endpoints\`.
   - Marks the workspace as configured via \`$Script:TruesecSettings.Session.WorkspaceConfigured = $true\`.
3.
If the session is already configured, the cmdlet informs the user and does not reconfigure the endpoints.
4.
If the provided Id cannot be found, an error is thrown.

This cmdlet is typically the first step in preparing the environment before calling any other Truesec API cmdlets.

## EXAMPLES

### EXAMPLE 1
```powershell
Set-TSWorkspace -Id "abc123"
# Retrieves all workspaces, selects the workspace with id "abc123", injects the id into all endpoint URLs, and marks the session as configured.
```

### EXAMPLE 2
```powershell
Set-TSWorkspace -Id "prod-primary"
# Initializes the session using the workspace whose id matches "prod-primary".
# If the workspace is already configured, a message explaining this is returned.
```

## PARAMETERS

### -Id
The unique workspace identifier you want to configure the current session to use.
This value must match an existing workspace returned by the Truesec workspaces endpoint.
Mandatory.

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

### None. This cmdlet does not accept pipeline input directly.
## OUTPUTS

### None by default.
### If successful, updates global Truesec session and endpoint state.
### If the workspace cannot be found or retrieved, an exception is thrown.
## NOTES
Author: Bufab Global IT, Cybersecurity department

Requirements:
- \`$Script:TruesecSettings.Endpoints.Workspaces\` must contain the base URI for listing workspaces.
- Endpoint definitions under \`$Script:TruesecSettings.Endpoints.*\` may contain the \`{workspaceId}\` placeholder,
  which is replaced during configuration.
- \`$Script:TruesecSettings.Session.ApiCredentials\` must already be set.
- \`$Script:TruesecSettings.Session.AccessToken\` must be valid or will be refreshed.

Helper functions expected:
- Confirm-NeedNewAccessToken
- Get-AccessToken
- (Optional) Reset-Workspace for resetting workspace configuration.

Behavior:
- If the provided Id does not match any workspace, the cmdlet throws an error.
- If the workspace is already configured, the cmdlet does not apply configuration again and emits an informational message.

Security:
- Access tokens are inserted into the Authorization header using the Bearer token format.

## RELATED LINKS

[Reset-Workspace](Reset-TSWorkspace.md)

[Get-AccessToken](Get-AccessToken.md)

[Confirm-NeedNewAccessToken](Confirm-NeedNewAccessToken.md)

[Get-TSWorkspace](Get-TSWorkspace.md)