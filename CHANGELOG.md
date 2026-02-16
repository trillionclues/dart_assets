# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-02-16

### Fixed
- Asset paths now use forward slashes on Windows (fixes generated code containing backslashes)

### Changed
- Bumped dependency versions (image, yaml_edit, mason_logger, watcher, path, dart_style, io)
- Removed Codecov integration from CI workflow
- Moved docs/ to notes/ per pub.dev convention

## [0.1.0] - 2026-02-16

### Added
- CLI with 7 commands: `watch`, `gen`, `optimize`, `unused`, `clean`, `check`, `doctor`
- File watcher with debounced event processing and automatic pubspec + code regeneration
- Type-safe Dart code generation from asset files (`lib/gen/assets.dart`)
- Pubspec.yaml asset list auto-management (add/remove on file changes)
- Image optimization via traditional compression (PNG level, JPEG quality control)
- Unused asset detection by scanning Dart source files for path references
- Missing asset detection (pubspec entries without matching files on disk)
- Asset size validation with configurable limits
- CI-friendly `check` command with non-zero exit codes on failure
- Project health diagnostics via `doctor` command
- Configurable via `dart_assets.yaml` (watch debounce, output path, class name, quality, size limits)
- NamingConverter for safe camelCase Dart identifiers from file names
- Example test project at `example/test_project/` for local CLI testing
- CI/CD pipelines (GitHub Actions for lint/test/coverage + tag-triggered pub.dev publish)
- 33 unit and integration tests

### Notes
- Image optimization uses the `image` Dart package for traditional compression (PNG level tuning, JPEG quality reduction). WebP encoding is not yet supported
— the package only includes a WebP decoder. Future versions may integrate AI-powered optimization (e.g. Gemini 2.5 for smart compression/format selection) or native tools like `cwebp`.

[0.2.0]: https://github.com/trillionclues/dart_assets/releases/tag/v0.2.0
[0.1.0]: https://github.com/trillionclues/dart_assets/releases/tag/v0.1.0
