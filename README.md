# delphi-coverage

![delphi-coverage logo](https://continuous-delphi.github.io/assets/logos/delphi-coverage-480x270.png)

[![Delphi](https://img.shields.io/badge/delphi-red)](https://www.embarcadero.com/products/delphi)
[![CI](https://github.com/continuous-delphi/delphi-coverage/actions/workflows/ci.yml/badge.svg)](https://github.com/continuous-delphi/delphi-coverage/actions/workflows/ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/continuous-delphi/delphi-coverage?display_name=release)](https://github.com/continuous-delphi/delphi-coverage/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Continuous Delphi](https://img.shields.io/badge/org-continuous--delphi-red)](https://github.com/continuous-delphi)

PowerShell code coverage orchestrator for Delphi projects, wrapping coverage engines behind a unified interface.

## Overview

`delphi-coverage` simplifies running Delphi code coverage analysis. It wraps
coverage engines (DelphiCodeCoverage, radCodeCoverage) with clean parameters,
structured output, threshold enforcement, and badge generation.

Designed for use as a standalone command or as a bundled tool inside
[delphi-powershell-ci](https://github.com/continuous-delphi/delphi-powershell-ci).

---

## Running the Tool

If `delphi-coverage` is on your PATH:

```powershell
delphi-coverage -Execute test\Win32\Debug\MyApp.Tests.exe `
    -MapFile test\Win32\Debug\MyApp.Tests.map -SourceDir source\
```

Otherwise, run it directly:

```powershell
pwsh -File .\source\delphi-coverage.ps1 -Execute test\Win32\Debug\MyApp.Tests.exe `
    -MapFile test\Win32\Debug\MyApp.Tests.map -SourceDir source\
```

## PowerShell Compatibility

Runs on the widely available Windows PowerShell 5.1 (`powershell.exe`)
and the newer PowerShell 7+ (`pwsh`).

---

## Features

- Wraps coverage engines behind a unified, documented interface
- Coverage threshold enforcement with exit code 6 on failure
- Badge generation (self-contained SVG or Shields.io JSON endpoint)
- Coverage threshold enforcement -- fail the build if coverage drops below a minimum
- MAP file validation (detects segment-only maps before running)
- Structured JSON output via `-OutputFile` for CI integration
- Multiple source directories via comma-separated `-SourceDir`

---

## Supported Engines

| Engine | Status | Notes |
|--------|--------|-------|
| `DelphiCodeCoverage` | Supported | Open source, Win32/Win64, MAP-file based |
| `radCodeCoverage` | Supported | Shares DelphiCodeCoverage CLI conventions, adds markdown, and LCOV output |
| `CoverageValidator` | Future | Commercial (Software Verify) |

---

## -Execute / -MapFile (explicit mode)

Path to the test executable and its detailed MAP file. Both are required unless `-Dproj` is used.

```powershell
delphi-coverage -Execute test\Win32\Debug\MyApp.Tests.exe `
    -MapFile test\Win32\Debug\MyApp.Tests.map
```

---

## -Dproj (auto-discovery mode)

Pass a `.dproj` file and the engine auto-discovers the executable, MAP file,
units, and source paths. 

When `-Dproj` is provided, `-Execute` and `-MapFile` are not required.
Additional `-SourceDir`, `-Units`, and `-ExcludeUnits` flags supplement
what the engine discovers.

```powershell
delphi-coverage -Dproj test\MyApp.Tests.dproj
delphi-coverage -Dproj test\MyApp.Tests.dproj -Engine radCodeCoverage
```

---

## -Engine

Which coverage engine to use. Default: `DelphiCodeCoverage`.

The engine executable must be on PATH or specified via `-EnginePath`.

```powershell
delphi-coverage -Execute test.exe -MapFile test.map -Engine radCodeCoverage
```

---

## -EnginePath

Explicit path to the coverage engine executable. Overrides PATH discovery.
Use this for platform-specific variants (e.g., `CodeCoverage.x64.exe` or
`radCodeCoverage.x64.exe`).

```powershell
delphi-coverage -Execute test.exe -MapFile test.map `
    -EnginePath C:\tools\radCodeCoverage.x64.exe
```

---

## -SourceDir

Directories containing Delphi source files, passed as comma-separated
values. Each path gets a separate `-sp` flag when invoking the engine.

```powershell
delphi-coverage -Execute test.exe -MapFile test.map -SourceDir source\,lib\
```

---

## -Units

Unit name patterns to include in coverage measurement. Supports wildcards.
Comma-separated when passed via `-File` mode. When empty, all units are
included.

```powershell
delphi-coverage -Execute test.exe -MapFile test.map -SourceDir source\ `
    -Units MyApp.Core.*,MyApp.Utils.*
```

---

## -ExcludeUnits

Unit name patterns to exclude from coverage measurement. Comma-separated
when passed via `-File` mode.

```powershell
delphi-coverage -Execute test.exe -MapFile test.map -SourceDir source\ `
    -Units MyApp.* -ExcludeUnits MyApp.Generated.*
```

---

## -OutputDir

Directory for coverage reports. Default: `coverage/`. Created automatically
if it does not exist.

```powershell
delphi-coverage -Execute test.exe -MapFile test.map -OutputDir reports\coverage
```

---

## -Formats

Output format(s) for coverage reports. Default: `html`. Comma-separated
when specifying multiple formats.

| Format | Description |
|--------|-------------|
| `html` | Human-readable HTML report |
| `xml` | DelphiCodeCoverage XML format |
| `emma` | Emma XML format |
| `lcov` | LCOV tracefile format (for Codecov, Coveralls, genhtml) |
| `cobertura` | Cobertura XML format (for CI tools) |
| `md` | Markdown coverage report |

```powershell
delphi-coverage -Execute test.exe -MapFile test.map -Formats html,lcov,md
```

---

## -Threshold

Minimum coverage percentage required. When set to a value greater than 0,
the tool fails (exit code 6) if coverage is below the threshold.

```powershell
# Fail if coverage drops below 60%
delphi-coverage -Execute test.exe -MapFile test.map -Threshold 60
```

Default: `0` (disabled -- any coverage percentage passes).

---

## -Arguments

Extra command-line arguments passed to the test executable at runtime.
Comma-separated when passed via `-File` mode.

```powershell
delphi-coverage -Execute test.exe -MapFile test.map -Arguments -b,-l:Warning
```

---

## -TimeoutSeconds

Maximum time in seconds for the coverage run. If exceeded, the engine
process is killed and the step fails. Default: `300`.

```powershell
delphi-coverage -Execute test.exe -MapFile test.map -TimeoutSeconds 600
```

---

## -Badge

Generates a coverage badge file. The output format is determined by the
file extension.

### SVG Badge

Self-contained SVG with no external dependencies. Commit it to the repo
or host on GitHub Pages.

```powershell
delphi-coverage -Execute test.exe -MapFile test.map -Badge docs/coverage-badge.svg
```

README usage:
```markdown
![coverage](docs/coverage-badge.svg)
```

### Shields.io JSON

JSON file in Shields.io's endpoint schema. Host it and reference with a
dynamic badge URL.

```powershell
delphi-coverage -Execute test.exe -MapFile test.map -Badge docs/coverage.json
```

README usage:
```markdown
![coverage](https://img.shields.io/endpoint?url=https://yourhost.com/coverage.json)
```

### Color Thresholds

| Coverage | Color |
|----------|-------|
| >= 80% | green |
| >= 60% | yellow |
| < 60% | red |

---

## -OutputFile

Path to write a structured JSON result file for CI tool integration.

```json
{
  "engine": "radCodeCoverage",
  "execute": "test/Win64/Debug/MyApp.Tests.exe",
  "exitCode": 0,
  "success": true,
  "coveragePercent": 73.4,
  "linesCovered": 1842,
  "linesTotal": 2510,
  "threshold": 60,
  "thresholdMet": true,
  "outputDir": "coverage/",
  "formats": ["html", "lcov"],
  "badge": "docs/coverage-badge.svg",
  "duration": 12.3
}
```

---

## Exit Codes

```text
  0 = success: coverage run completed, threshold met (or no threshold set)
  1 = unexpected error
  2 = invalid arguments (missing params, bad format, segment-only MAP file)
  3 = engine executable not found
  4 = test executable, MAP file, or .dproj not found
  5 = coverage run failed (engine exited non-zero)
  6 = threshold not met (coverage below minimum percentage)
```

---

## Examples

### Basic coverage run

```powershell
delphi-coverage -Execute test\Win32\Debug\MyApp.Tests.exe `
    -MapFile test\Win32\Debug\MyApp.Tests.map `
    -SourceDir source\
```

### Using -Dproj with radCodeCoverage

```powershell
delphi-coverage -Dproj test\MyApp.Tests.dproj `
    -Engine radCodeCoverage `
    -EnginePath radCodeCoverage.x64.exe `
    -Formats html,lcov,md `
    -Badge assets/coverage/coverage-badge.svg
```

### Multiple source directories

```powershell
delphi-coverage -Execute test\Win64\Debug\MyApp.Tests.exe `
    -MapFile test\Win64\Debug\MyApp.Tests.map `
    -SourceDir source\,lib\,shared\
```

### With threshold and LCOV output

```powershell
delphi-coverage -Execute test\Win32\Debug\MyApp.Tests.exe `
    -MapFile test\Win32\Debug\MyApp.Tests.map `
    -SourceDir source\ -Units MyApp.* `
    -OutputDir coverage\ -Formats html,lcov `
    -Threshold 60
```

### With badge generation

```powershell
delphi-coverage -Execute test\Win32\Debug\MyApp.Tests.exe `
    -MapFile test\Win32\Debug\MyApp.Tests.map `
    -SourceDir source\ -Badge assets/coverage/coverage-badge.svg
```

### Full pipeline example (via delphi-powershell-ci config)

```json
{
  "pipeline": [
    { "action": "Build", "jobs": [
      { "name": "Test project",
        "projectFile": "test/MyApp.Tests.dproj",
        "platform": "Win64", "configuration": "Debug",
        "defines": ["CI"] }
    ]},
    { "action": "Coverage", "jobs": [
      { "name": "Unit test coverage",
        "dproj": "test/MyApp.Tests.dproj",
        "engine": "radCodeCoverage",
        "sourceDir": ["/source", "/lib"],
        "formats!": ["html", "lcov", "md"],
        "threshold": 60,
        "badge": "assets/coverage/coverage-badge.svg" }
    ]}
  ]
}
```

---

## Build Prerequisites

Coverage requires the test project to be built with:
- **Debug information** enabled
- **Detailed MAP file** output (linker setting "Detailed" or `DCC_MapFile=3`)

Without these, the coverage engine cannot map execution to source lines.

When using `-Dproj` mode, the engine reads these settings from the project
file directly.

---

## Running Tests

Requires PowerShell 7+, Pester 5.7+, and PSScriptAnalyzer.

```powershell
./tests/run-tests.ps1
```

---

## Maturity

This repository is currently `incubator` and is under active development.
It will graduate to `stable` once:

- At least one downstream consumer exists.

Until graduation, breaking changes may occur.

---

## Continuous-Delphi

This tool is part of the [Continuous-Delphi](https://github.com/continuous-delphi)
ecosystem, focused on strengthening Delphi's continued success.

![continuous-delphi logo](https://continuous-delphi.github.io/assets/logos/continuous-delphi-480x270.png)
