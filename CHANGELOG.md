# `delphi-coverage` Changelog

All notable changes to this project will be documented in this file.

---

### [1.1.1] 2026-05-20

- fix DCC engine argument escaping: prefix `-` with `^` in test arguments passed via `-a`
[#2](https://github.com/continuous-delphi/delphi-coverage/issues/2)
- DCC engine auto-discovers units from MAP file when `-Units` not specified
[#3](https://github.com/continuous-delphi/delphi-coverage/issues/3)

---

## [1.1.0] 2026-05-17

- added `covdb` output format for radCodeCoverage SQLite database output (#1)
- `covdb` produces a `coverage.db` file with metadata, files, and lines tables
- validates that `covdb` format requires `-Engine radCodeCoverage`

---

## [1.0.0] 2026-05-12

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
