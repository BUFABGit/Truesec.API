# Connect-TruesecAPI

## SYNOPSIS
Connects to the Truesec API by establishing API credentials and optionally obtaining a new access token.

## SYNTAX

### Manual
```powershell
Connect-TruesecAPI -Credential <PSCredential> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### KeePass
```powershell
Connect-TruesecAPI -APIKeyName <String> [-KeePassPath <String>] -KeePassDB <String> -KeePassPW <SecureString>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### 1Password
```powershell
Connect-TruesecAPI -APIKeyName <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Connect-TruesecAPI initializes API credentials used by the Truesec module and, if required, acquires a new access token.
You can provide the API credentials in three ways:
- **Manual**: Pass a PSCredential that contains the API username and key/secret.
- **1Password**: Retrieve the API key using the 1Password CLI (requires \`op.exe\` on PATH) by specifying the name of the entry holding the key.
- **KeePass**: Retrieve the API key from a KeePass database by providing the KeePass executable path (if not default), the database file path, and the KeePass database password.

The function stores the credential in \`$Script:TruesecSettings.Session.ApiCredentials\`.
If a new token is needed, it calls \`Get-AccessToken\` using the stored credentials.

## EXAMPLES

### EXAMPLE 1
```powershell
Connect-TruesecAPI -Credential (Get-Credential)
# Uses a manually supplied PSCredential to set the API credentials and, if required, fetches a new access token.
```

### EXAMPLE 2
```powershell
Connect-TruesecAPI -APIKeyName "Truesec API Key (Prod)" -Verbose
# Retrieves the API key from the 1Password CLI using the specified item name and sets the credentials. Requires `op.exe` to be installed and available on PATH.
```

### EXAMPLE 3
```powershell
$kpw = Read-Host "KeePass DB Password" -AsSecureString
Connect-TruesecAPI -APIKeyName "Truesec API Key (Prod)" -KeePassDB "C:\Secrets\vault.kdbx" -KeePassPW $kpw
# Fetches the API key from the KeePass database and sets the credentials. Uses the default KeePass installation path.
```

## PARAMETERS

### -Credential
Manual mode.
A PSCredential containing the API username (UserName) and API key/secret (Password).
Mandatory in the **Manual** parameter set.

```yaml
Type: PSCredential
Parameter Sets: Manual
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -APIKeyName
Name of the vault entry that contains the API key/secret.
- In the **1Password** parameter set, this is the item name passed to the 1Password CLI.
- In the **KeePass** parameter set, this is the entry name in the KeePass database.
Mandatory in the **1Password** and **KeePass** parameter sets.

```yaml
Type: String
Parameter Sets: KeePass, 1Password
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeePassPath
Path to \`KeePass.exe\`.
If a folder is supplied, the function appends \`KeePass.exe\`.
Defaults to \`C:\Program Files\KeePass Password Safe 2\KeePass.exe\`.
Optional; only used in the **KeePass** parameter set.

```yaml
Type: String
Parameter Sets: KeePass
Aliases:

Required: False
Position: Named
Default value: C:\Program Files\KeePass Password Safe 2\KeePass.exe
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeePassDB
Full path to the KeePass database file (\`.kdbx\`) containing the API key entry.
Mandatory in the **KeePass** parameter set.

```yaml
Type: String
Parameter Sets: KeePass
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeePassPW
Password for the KeePass database as a SecureString.
Mandatory in the **KeePass** parameter set.

```yaml
Type: SecureString
Parameter Sets: KeePass
Aliases:

Required: True
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

### None. You cannot pipe objects directly to Connect-TruesecAPI.
## OUTPUTS

### None. This cmdlet does not produce pipeline output.
### Side effects:
### - Sets `$Script:TruesecSettings.Session.ApiCredentials`.
### - May obtain and cache a new access token (via `Get-AccessToken`) if `Confirm-NeedNewAccessToken` evaluates to true.
## NOTES
Author: Bufab Global IT, Cybersecurity department
Requirements:
- **1Password** parameter set needs 1Password CLI (\`op.exe\`) installed and on PATH.
- **KeePass** parameter set currently supports Windows PowerShell 5.1 only.
The cmdlet throws if PS major version \> 5.
- The function validates KeePass paths and database existence before attempting retrieval.

## RELATED LINKS

[Get-AccessToken](Get-AccessToken.md)

[Get-ApiKey](Get-ApiKey.md)

[Confirm-NeedNewAccessToken](Confirm-NeedNewAccessToken.md)

