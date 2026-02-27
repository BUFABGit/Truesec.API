# Reset-TSWorkspace

## SYNOPSIS
Resets the configured Truesec workspace and restores the original workspace settings file.

## SYNTAX

```
Reset-TSWorkspace [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reset-TSWorkspace clears the currently configured Truesec workspace state and reloads the
original workspace configuration from disk.
 
This is typically used when switching to another workspace or when the session has become
misconfigured.

The cmdlet performs the following steps:
1.
Verifies that a workspace has been configured.
If not, the cmdlet stops with an error.
2.
Ensures a valid access token exists, refreshing it if required.
3.
Prompts the user for confirmation before making any changes.
4.
If the user confirms:
   - Clears the global \`$TruesecSettings\` variable.
   - Reloads the settings JSON file from the path stored in \`$TruesecSettings.SettingsPath\`.
   - Re-attaches the SettingsPath property to the newly loaded object.
5.
If the user declines:
   - Aborts the operation and writes a cancellation message.

Resetting the workspace does **not** remove stored API credentials, but it does require the
session to reinitialize the workspace using Set-TSWorkspace.

## EXAMPLES

### EXAMPLE 1
```powershell
Reset-TSWorkspace
# Prompts the user for confirmation and, if confirmed, resets the workspace configuration.
```

### EXAMPLE 2
```powershell
Reset-TSWorkspace -Verbose
# Runs the reset process and shows verbose diagnostic output as applicable.
```

## PARAMETERS

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

### None.  
### Writes confirmation or cancellation messages to the pipeline.
## NOTES
Author: Bufab Global IT, Cybersecurity department  
A workspace must have been previously configured before this cmdlet can be used.

Helper functions used:
- Confirm-NeedNewAccessToken
- Get-AccessToken

Security:
- Access tokens are handled using the standard Bearer authorization header format.

## RELATED LINKS

[Set-TSWorkspace]()

[Confirm-NeedNewAccessToken]()

[Get-AccessToken]()

