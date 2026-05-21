# tests/pwsh/delphi-coverage.MapParsing.Tests.ps1
# Tests for MAP file unit auto-discovery (Get-MapFileUnits).

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'delphi-coverage -- MAP file unit parsing' {

    BeforeAll {
        $script:FixturesPath = (Resolve-Path (Join-Path $PSScriptRoot 'fixtures')).Path

        # Define the function under test inline (mirrors source/delphi-coverage.ps1)
        function Get-MapFileUnits {
            param([string]$Path)
            $units = Get-Content -LiteralPath $Path |
                Where-Object { $_ -match '^\s*Line numbers for (.+)\(' } |
                ForEach-Object { $Matches[1] }
            return @($units | Select-Object -Unique)
        }
    }

    Context 'Get-MapFileUnits' {

        It 'extracts unit names from a detailed MAP file' {
            $mapFile = Join-Path $script:FixturesPath 'sample.map'
            $units = Get-MapFileUnits -Path $mapFile
            $units | Should -Contain 'MyApp.Core'
            $units | Should -Contain 'MyApp.Utils'
            $units | Should -HaveCount 2
        }

        It 'returns an empty array for a segment-only MAP file' {
            $mapFile = Join-Path $script:FixturesPath 'segment-only.map'
            $units = Get-MapFileUnits -Path $mapFile
            $units | Should -HaveCount 0
        }

        It 'deduplicates repeated unit names' {
            $tempMap = Join-Path $TestDrive 'dup.map'
            @(
                ' Start         Length     Name                   Class'
                ' 0001:00001000 00010000H .text                  CODE'
                ''
                ' Line numbers for MyApp.Core(source\MyApp.Core.pas) segment .text'
                ''
                '    10 0001:00001000    11 0001:00001010'
                ''
                ' Line numbers for MyApp.Core(source\MyApp.Core.pas) segment .text'
                ''
                '    20 0001:00002000    21 0001:00002010'
            ) | Set-Content -LiteralPath $tempMap
            $units = Get-MapFileUnits -Path $tempMap
            $units | Should -Contain 'MyApp.Core'
            $units | Should -HaveCount 1
        }

    }

}
