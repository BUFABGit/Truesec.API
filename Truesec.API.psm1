$ModuleRoot = $PSScriptRoot
$Settings   = Join-Path -Path $ModuleRoot -ChildPath (Join-Path -Path 'Resources' -ChildPath 'Settings.json')

try {
    Get-Variable -Name TruesecSettings -Scope Script -ErrorAction Stop
    $SettingsExist = $true
}
catch {
    $SettingsExist = $false
}

$Private = @(Get-ChildItem -Path (Join-Path -Path $ModuleRoot -ChildPath 'Private') -Filter *.ps1 -ErrorAction SilentlyContinue)
$Public  = @(Get-ChildItem -Path (Join-Path -Path $ModuleRoot -ChildPath 'Public') -Filter *.ps1 -ErrorAction SilentlyContinue)

foreach ($Import in @($Private + $Public)) {
    try {
        . $Import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

if (-not ($SettingsExist)) {
    $Json = Get-Content -Path $Settings | ConvertFrom-Json
    New-Variable -Name TruesecSettings -Value $Json -Scope Script -Force
    $TruesecSettings | Add-Member -MemberType NoteProperty -Name SettingsPath -Value $Settings
    Export-ModuleMember -Variable TruesecSettings
    $SettingsExist  = $true
}
else {
    Write-Verbose "Settings variable found, reusing current."
}

Export-ModuleMember -Function $Public.Basename
Export-ModuleMember -Function $Private.Basename