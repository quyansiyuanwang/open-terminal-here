# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-16

### Added

- Finder Quick Action that opens kitty at the current Finder folder without
  requiring a selection.
- Reuse of an existing kitty window as a new tab through kitty remote control
  (`kitty @ launch --type=tab --cwd=...`).
- Fallback to a new kitty window when no remote-control socket is available.
- `install.sh` and `uninstall.sh`.
- Bilingual documentation (`README.md`, `README.zh-CN.md`).
- `kitty.conf.snippet` with the required remote-control settings.
