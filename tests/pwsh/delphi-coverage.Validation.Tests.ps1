# tests/pwsh/delphi-coverage.Validation.Tests.ps1
# Tests for parameter validation and error handling.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'delphi-coverage -- validation' {

    BeforeAll {
        $script:ScriptPath   = (Resolve-Path (Join-Path $PSScriptRoot '../../source/delphi-coverage.ps1')).Path
        $script:FixturesPath = (Resolve-Path (Join-Path $PSScriptRoot 'fixtures')).Path
    }

    Context 'version info' {

        It 'exits with code 0 for -Version' {
            & pwsh -NoProfile -File $script:ScriptPath -Version
            $LASTEXITCODE | Should -Be 0
        }

        It 'outputs JSON for -Version -Format json' {
            $output = & pwsh -NoProfile -File $script:ScriptPath -Version -Format json
            $parsed = $output | ConvertFrom-Json
            $parsed.tool.name | Should -Be 'delphi-coverage'
            $parsed.tool.version | Should -Not -BeNullOrEmpty
        }

    }

    Context 'missing files' {

        It 'exits with code 4 when test executable not found' {
            $mapFile = Join-Path $script:FixturesPath 'sample.map'
            & pwsh -NoProfile -File $script:ScriptPath -Execute 'C:\nonexistent\test.exe' -MapFile $mapFile 2>$null
            $LASTEXITCODE | Should -Be 4
        }

        It 'exits with code 4 when MAP file not found' {
            # Use the script itself as a stand-in for an existing executable
            & pwsh -NoProfile -File $script:ScriptPath -Execute $script:ScriptPath -MapFile 'C:\nonexistent\test.map' 2>$null
            $LASTEXITCODE | Should -Be 4
        }

    }

    Context 'MAP file validation' {

        It 'exits with code 2 when MAP file has no line number info' {
            $segmentMap = Join-Path $script:FixturesPath 'segment-only.map'
            & pwsh -NoProfile -File $script:ScriptPath -Execute $script:ScriptPath -MapFile $segmentMap 2>$null
            $LASTEXITCODE | Should -Be 2
        }

    }

    Context 'invalid formats' {

        It 'exits with code 2 for an invalid output format' {
            $mapFile = Join-Path $script:FixturesPath 'sample.map'
            & pwsh -NoProfile -File $script:ScriptPath -Execute $script:ScriptPath -MapFile $mapFile -Formats 'pdf' 2>$null
            $LASTEXITCODE | Should -Be 2
        }

    }

}
