# Get-AccessToken

## SYNOPSIS
Retrieves or refreshes the Truesec API access token used for authentication.

## SYNTAX

```
Get-AccessToken [[-ApiCredentials] <PSCredential>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-AccessToken requests a new access token from the Truesec authentication endpoint
when the existing token is missing or expired.
 
Token freshness is evaluated by Confirm-NeedNewAccessToken, which checks whether the
current token is older than 4 hours.

When a refresh is required, the cmdlet:
1.
Constructs the JSON request body using:
   - The BaseAppUri (audience)
   - The client_id (API username)
   - The client_secret (API key)
2.
Sends an authenticated POST request to the AuthUri endpoint.
3.
Stores the resulting token (as a SecureString) in:
   - \`$Script:TruesecSettings.Session.AccessToken\`
   - \`$Script:TruesecSettings.Session.AccessTokenCreated\`

If the token is still valid, the cmdlet writes "Current token still active."

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AccessToken -ApiCredentials (Get-Credential)
# Requests a new access token using the supplied PSCredential and stores it in session configuration.
```

### EXAMPLE 2
```powershell
Get-AccessToken
# Uses previously stored API credentials to refresh the access token if required.
```

## PARAMETERS

### -ApiCredentials
(Optional) A PSCredential object containing the API client_id and client_secret.
If omitted, the function uses \`$Script:TruesecSettings.Session.ApiCredentials\`.

```yaml
Type: PSCredential
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

### None.  
### This cmdlet does not accept pipeline input.
## OUTPUTS

### None directly.  
### On success, the function **updates global session state** with a new token.  
### If the token request fails, an exception is thrown.
## NOTES
Author: Bufab Global IT, Cybersecurity department

Behavior:
- Tokens older than 4 hours automatically trigger a refresh.
- Newly retrieved tokens are stored as SecureString values.
- Timestamp is recorded in ISO-like "yyyy-MM-ddTHH:mm:ss" format.

Security:
- Authentication uses the client_credentials OAuth2 flow.
- Sensitive values (client_secret, access_token) are kept as SecureStrings in memory.

Related configuration fields:
- \`$Script:TruesecSettings.Endpoints.AuthUri\`
- \`$Script:TruesecSettings.Endpoints.BaseAppUri\`
- \`$Script:TruesecSettings.Session.ApiCredentials\`

## RELATED LINKS

[Confirm-NeedNewAccessToken]()

[Set-TSWorkspace]()

