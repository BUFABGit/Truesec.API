# Confirm-NeedNewAccessToken

## SYNOPSIS
Determines whether a new Truesec API access token is required.

## SYNTAX

```
Confirm-NeedNewAccessToken [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Confirm-NeedNewAccessToken evaluates the age of the current stored access token and returns a
Boolean value indicating whether a new token should be retrieved.

The function checks:
1.
Whether \`$TruesecSettings.Session.AccessTokenCreated\` exists.
2.
If it does, whether more than **4 hours** have passed since token creation.
3.
If no timestamp exists, it assumes a new token is required.

The cmdlet does not request or refresh the token itself - it only reports whether a refresh is needed.
 
Token renewal is performed by Get-AccessToken.

## EXAMPLES

### EXAMPLE 1
```powershell
Confirm-NeedNewAccessToken
# Returns $true or $false depending on token age.
```

### EXAMPLE 2
```powershell
if (Confirm-NeedNewAccessToken) { Get-AccessToken -APICredentials $Creds }
# Checks token freshness and refreshes it if needed.
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

### None.  
### This cmdlet does not accept pipeline input.
## OUTPUTS

### System.Boolean  
### - **$true**  → A new access token is required.  
### - **$false** → The existing token is still valid (less than 4 hours old).
## NOTES
Author: Bufab Global IT, Cybersecurity department

Behavior:
- If no token creation time exists, the function defaults to requiring a new token.
- Token age is calculated using New-TimeSpan.
- The returned Boolean value is emitted in the end block for easy consumption.

Security:
- This function does not handle credentials or modify token data - it only evaluates timestamps.

## RELATED LINKS

[Get-AccessToken]()

[Initialize-TSWorkspace]()

