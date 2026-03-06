# Get-ApiKey

## SYNOPSIS
Retrieves API credentials (username + secret) from a specified secure source.

## SYNTAX

### KeePass
```
Get-ApiKey -Source <String> -APIKeyName <String> -KeePassPath <String> -KeePassDB <String>
 -KeePassPW <SecureString> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### 1Password
```
Get-ApiKey -Source <String> -APIKeyName <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-ApiKey returns a PSCredential containing the API username and secret from one of the supported sources:
- **1Password**: Uses the 1Password CLI (\`op\`) to read a vault item and extract the username and password.
- **KeePass**: Loads the KeePass assemblies, opens the specified \`.kdbx\` database, searches for an entry by name, and extracts the username and password.
- **Internal**: Reserved for future implementations (e.g., secure internal store).

The resulting credential is typically saved to \`$Script:TruesecSettings.Session.ApiCredentials\` by callers and later used by Get-AccessToken.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-ApiKey -Source 1Password -APIKeyName "Truesec API Key (Prod)"
# Fetches the API credential from a 1Password item and returns it as a PSCredential.
```

### EXAMPLE 2
```powershell
$kpw = Read-Host "KeePass DB Password" -AsSecureString
Get-ApiKey -Source KeePass -APIKeyName "Truesec API Key (Prod)" -KeePassPath "C:\Program Files\KeePass Password Safe 2\KeePass.exe" -KeePassDB "C:\Secrets\vault.kdbx" -KeePassPW $kpw
# Opens the KeePass database, locates the specified entry, and returns the API credential.
```

## PARAMETERS

### -Source
Specifies where the API key should be retrieved from.
Valid values:
- 1Password
- KeePass
- Internal

Mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -APIKeyName
The entry name containing the API key/secret:
- For **1Password**: the item name in the vault.
- For **KeePass**: the entry title to search for in the database.

Mandatory for **1Password** and **KeePass** parameter sets.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeePassPath
Path to the KeePass executable/assembly used to load the required KeePass types.
Mandatory for the **KeePass** parameter set.

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

### -KeePassDB
Full path to the KeePass database file (\`.kdbx\`).
Mandatory for the **KeePass** parameter set.

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
SecureString password for the KeePass database.
Mandatory for the **KeePass** parameter set.

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

### None. This cmdlet does not accept pipeline input.
## OUTPUTS

### System.Management.Automation.PSCredential  
### A credential object whose UserName is the API client id and whose Password is the API secret.
## NOTES
Author: Bufab Global IT, Cybersecurity department

Requirements & Behavior:
- \`$Script:TruesecSettings\` must be initialized before calling this cmdlet.
- **1Password**: Requires the 1Password CLI (\`op\`) to be installed and available on PATH.
The item must contain a *username* field and a *password* field.
- **KeePass**: Loads KeePass assemblies from the provided path, opens the database with the given password, searches by entry title, and constructs a PSCredential from the entry's UserName and Password fields.
- **Internal**: Placeholder for future use; currently returns nothing.
- On failure (e.g., item not found, file/path errors, CLI/assembly errors) the cmdlet throws with a descriptive message.

Security:
- API secrets are converted to \`SecureString\` and kept in memory only for the duration needed to build the PSCredential.

## RELATED LINKS

[Get-AccessToken](Get-AccessToken.md)

[Set-TSWorkspace](Set-TSWorkspace.md)