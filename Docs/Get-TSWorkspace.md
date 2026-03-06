# Get-TSWorkspace

## SYNOPSIS
Retrieves information about available Truesec workspaces.

## SYNTAX

```
Get-TSWorkspace [[-WorkspaceName] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-TSWorkspace queries the Truesec Workspaces API endpoint and returns:
- All available workspaces, or
- A specific workspace when a name is provided via -WorkspaceName.

Before executing the request, the cmdlet ensures a valid access token is available.
If the current token is missing or expired, a new one is automatically acquired using Get-AccessToken.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-TSWorkspace
# Retrieves all available Truesec workspaces for the current session.
```

### EXAMPLE 2
```powershell
Get-TSWorkspace -WorkspaceName "Finance"
# Retrieves only the workspace with the name "Finance".
```

## PARAMETERS

### -WorkspaceName
Specifies the name of a workspace to return.
If omitted, all available workspaces are returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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

### A workspace object or a collection of workspace objects returned by the Truesec API.
## NOTES
Author: Bufab Global IT, Cybersecurity department
A valid authenticated session is required.
A new access token is automatically retrieved when necessary.

## RELATED LINKS

[Confirm-NeedNewAccessToken](Confirm-NeedNewAccessToken.md)

[Get-AccessToken](Get-AccessToken.md)

[Set-TSWorkspace](Set-TSWorkspace.md)

