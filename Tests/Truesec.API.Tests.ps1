#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.6.0' }
# Truesec.API 1.1.0: module loading (portable paths), no bearer token in error output, Set-TSWorkspace picks the
# requested workspace, and the token request throws its own error. No network: Invoke-RestMethod is mocked.
#   Invoke-Pester ./Tests/Truesec.API.Tests.ps1 -Output Detailed
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Variables set in BeforeAll are read in the It blocks')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Test fixtures: fake token and secret, checked to never appear in output')]
param()

BeforeAll {
    $script:Manifest = Join-Path (Split-Path $PSScriptRoot -Parent) 'Truesec.API.psd1'
    function Initialize-TestModule {
        Remove-Module Truesec.API -Force -ErrorAction SilentlyContinue
        Import-Module $script:Manifest -Force
        InModuleScope Truesec.API {
            # A fresh session that needs no token request: configured workspace (placeholders replaced, as
            # Set-TSWorkspace does), recent token.
            foreach ($p in $Script:TruesecSettings.Endpoints.PSObject.Properties) { $p.Value = $p.Value.Replace('{workspaceId}', 'ws-test') }
            $Script:TruesecSettings.Session.WorkspaceConfigured = $true
            $Script:TruesecSettings.Session.AccessToken = ConvertTo-SecureString 'SECRET-TOKEN-123' -AsPlainText -Force
            $Script:TruesecSettings.Session.AccessTokenCreated = Get-Date -Format s
        }
    }
}

AfterAll { Remove-Module Truesec.API -Force -ErrorAction SilentlyContinue }

Describe 'Loading the module' {
    BeforeAll { Initialize-TestModule }
    It 'imports the public and private functions and the settings (paths built with Join-Path)' {
        Get-Command -Module Truesec.API -Name Get-TSIncident, Set-TSWorkspace, Connect-TruesecAPI, Format-TSRequestError | Should -HaveCount 4
        InModuleScope Truesec.API { $Script:TruesecSettings.Endpoints.AuthUri | Should -Match '^https://' }
    }
    It 'reports version 1.1.0' {
        (Get-Module Truesec.API).Version.ToString() | Should -Be '1.1.0'
    }
}

Describe 'Failed requests never output the bearer token' {
    BeforeEach {
        Initialize-TestModule
        Mock -ModuleName Truesec.API Invoke-RestMethod { throw 'Response status code does not indicate success: 403 (Forbidden).' }
    }
    It '<Name> throws a cleaned error and outputs nothing' -ForEach @(
        @{ Name = 'Get-TSIncident -Id'; Call = { Get-TSIncident -Id 'INC-1' } }
        @{ Name = 'Get-TSIncident -All'; Call = { Get-TSIncident -All -PageSize 10 } }
        @{ Name = 'Get-TSThreatEvent'; Call = { Get-TSThreatEvent -All } }
        @{ Name = 'Get-TSCyberExposureProfile'; Call = { Get-TSCyberExposureProfile -All } }
    ) {
        $out = $null
        $err = $null
        try { $out = & $Call *>&1 } catch { $err = $_ }
        $err | Should -Not -BeNullOrEmpty
        "$err" | Should -Match '^Truesec API request failed: GET /'
        "$err" | Should -Match '403'
        ($out | Out-String) + "$err" | Should -Not -Match 'SECRET-TOKEN-123|authorization'
    }
}

Describe 'Set-TSWorkspace' {
    BeforeEach {
        # A freshly loaded module (placeholders still in the endpoints) with a recent token, no workspace yet.
        Remove-Module Truesec.API -Force -ErrorAction SilentlyContinue
        Import-Module $script:Manifest -Force
        InModuleScope Truesec.API {
            $Script:TruesecSettings.Session.AccessToken = ConvertTo-SecureString 'SECRET-TOKEN-123' -AsPlainText -Force
            $Script:TruesecSettings.Session.AccessTokenCreated = Get-Date -Format s
        }
        Mock -ModuleName Truesec.API Invoke-RestMethod { @([pscustomobject]@{ id = 'ws-first' }, [pscustomobject]@{ id = 'ws-second' }) }
    }
    It 'configures the requested workspace, not the first one' {
        Set-TSWorkspace -Id 'ws-second'
        InModuleScope Truesec.API {
            $Script:TruesecSettings.Endpoints.Incidents | Should -Match '/workspaces/ws-second/incidents$'
            $Script:TruesecSettings.Session.WorkspaceConfigured | Should -BeTrue
        }
    }
    It 'throws for an unknown id' {
        { Set-TSWorkspace -Id 'nope' } | Should -Throw '*could not be retrieved*'
    }
}

Describe 'Token request' {
    BeforeEach {
        Remove-Module Truesec.API -Force -ErrorAction SilentlyContinue
        Import-Module $script:Manifest -Force
        Mock -ModuleName Truesec.API Invoke-RestMethod { throw 'Response status code does not indicate success: 401 (Unauthorized).' }
    }
    It 'throws its own error, without the client secret' {
        $cred = [pscredential]::new('client-id', (ConvertTo-SecureString 'SUPER-SECRET-456' -AsPlainText -Force))
        $err = $null
        try { Connect-TruesecAPI -Credential $cred } catch { $err = $_ }
        "$err" | Should -Match '^Truesec API request failed: POST /oauth/token\. .*401'
        "$err" | Should -Not -Match 'SUPER-SECRET-456'
    }
}

Describe 'Format-TSRequestError' {
    BeforeAll { Initialize-TestModule }
    It 'masks anything that looks like a bearer token and drops the query string' {
        InModuleScope Truesec.API {
            $rec = [System.Management.Automation.ErrorRecord]::new([Exception]::new('denied for Bearer abc.def-ghi'), 'x', 'NotSpecified', $null)
            $msg = Format-TSRequestError -ErrorRecord $rec -Method Get -Uri 'https://soc.example.test/workspaces/w/incidents?pageSize=10'
            $msg | Should -Be 'Truesec API request failed: GET /workspaces/w/incidents. denied for Bearer ***'
        }
    }
}
