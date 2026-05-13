# `delphi-coverage` Changelog

All notable changes to this project will be documented in this file.

---

## [0.1.0] 2026-05-12

- initial release with DelphiCodeCoverage and radCodeCoverage engine support
- `-Dproj` mode for auto-discovery of exe, map, units, and source paths
- multiple source directories via comma-separated `-SourceDir`
- output formats: html, xml, emma, lcov, cobertura, md
- coverage threshold enforcement (exit code 6 on failure)
- badge generation (self-contained SVG or Shields.io JSON endpoint)
- MAP file validation (rejects segment-only maps)
- structured JSON result output via `-OutputFile`

<br />
<br />

### `delphi-coverage` - a developer tool from Continuous Delphi

![continuous-delphi logo](https://continuous-delphi.github.io/assets/logos/continuous-delphi-480x270.png)

https://github.com/continuous-delphi
