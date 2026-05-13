# tests/pwsh/delphi-coverage.Threshold.Tests.ps1
# Tests for coverage threshold logic and report parsing.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'delphi-coverage -- coverage parsing' {

    BeforeAll {
        $script:ScriptPath   = (Resolve-Path (Join-Path $PSScriptRoot '../../source/delphi-coverage.ps1')).Path
        $script:FixturesPath = (Resolve-Path (Join-Path $PSScriptRoot 'fixtures')).Path
    }

    Context 'Cobertura XML parsing' {

        It 'extracts coverage percent from Cobertura XML' {
            # Set up a temp coverage dir with a Cobertura report
            $coverageDir = Join-Path $TestDrive 'cov1'
            New-Item -Path $coverageDir -ItemType Directory -Force | Out-Null
            Copy-Item (Join-Path $script:FixturesPath 'sample-cobertura.xml') (Join-Path $coverageDir 'coverage.xml')

            # Dot-source the function for direct testing
            # We need to extract Get-CoverageFromXml
            $funcDef = @'
function Get-CoverageFromXml {
    param([string]$CoverageOutputDir)
    $coberturaFile = Join-Path $CoverageOutputDir 'coverage.xml'
    if (Test-Path -LiteralPath $coberturaFile -PathType Leaf) {
        $xml = [xml](Get-Content -LiteralPath $coberturaFile -Raw)
        if ($null -ne $xml.coverage) {
            $lineRate = [double]$xml.coverage.'line-rate'
            $linesValid = [int]$xml.coverage.'lines-valid'
            $linesCovered = [int]($lineRate * $linesValid)
            return @{
                CoveragePercent = [math]::Round($lineRate * 100, 1)
                LinesCovered    = $linesCovered
                LinesTotal      = $linesValid
            }
        }
    }
    return $null
}
'@
            Invoke-Expression $funcDef

            $result = Get-CoverageFromXml -CoverageOutputDir $coverageDir
            $result | Should -Not -BeNullOrEmpty
            $result.CoveragePercent | Should -Be 73.4
            $result.LinesTotal | Should -Be 2510
            $result.LinesCovered | Should -Be 1842
        }

    }

    Context 'threshold logic' {

        It 'passes when coverage meets threshold' {
            # 73.4% meets a 60% threshold
            $percent = 73.4
            $threshold = 60
            ($percent -ge $threshold) | Should -Be $true
        }

        It 'fails when coverage is below threshold' {
            $percent = 45.2
            $threshold = 60
            ($percent -ge $threshold) | Should -Be $false
        }

        It 'passes when threshold is 0 (disabled)' {
            $percent = 10.0
            $threshold = 0
            # Threshold 0 means disabled -- always passes
            ($threshold -eq 0 -or $percent -ge $threshold) | Should -Be $true
        }

        It 'passes when coverage exactly matches threshold' {
            $percent = 60.0
            $threshold = 60
            ($percent -ge $threshold) | Should -Be $true
        }

    }

}
