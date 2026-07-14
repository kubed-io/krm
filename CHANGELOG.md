# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.17] - 2026-07-14

### Fixed

- `kubectl plan` is now executable, so `kubectl plan` resolves as a plugin instead of failing with `unknown command "plan"`.

## [0.0.16] - 2026-07-14

### Changed

- Dependabot PRs carry a `no changelog` label so they skip the changelog gate.

## [0.0.15] - 2026-07-14

### Added

- `kubectl plan` — read-only counterpart to `up`: renders with `build` and server-side-diffs against live (exit 0/1/>1), plus a membership-based applyset prune preview (`--no-prune` to skip); honors `KUBECTL_EXTERNAL_DIFF` (e.g. dyff).

### Removed

- `kubectl up --plan` — superseded by the first-class `kubectl plan` command.

## [0.0.14] - 2026-06-09

## [0.0.13] - 2026-06-09

## [0.0.12] - 2026-05-16

## [0.0.11] - 2026-01-31

## [0.0.10] - 2026-01-07

## [0.0.9] - 2025-11-11

- update versions of vscode and codeserver
- better bump and release
