# DEPLOYMENT & PUBLISHING

## Overview

Flutter packages are distributed via [pub.dev](https://pub.dev). This document covers building, testing, and publishing `dart_assets`.

---

## Prerequisites

### Required

- [ ] pub.dev account ([create here](https://pub.dev))
- [ ] Email verified
- [ ] Package name available (check: `dart pub get` in project)
- [ ] Valid LICENSE file
- [ ] Complete README.md
- [ ] CHANGELOG.md up to date

---

## Pre-Publishing Checklist

### 1. Package Metadata

**pubspec.yaml:**
```yaml
name: dart_assets
description: Professional asset management for Flutter projects. Auto-update pubspec.yaml, generate type-safe code, and optimize images.
version: 1.0.0
repository: https://github.com/trillionclues/dart_assets
homepage: https://github.com/trillionclues/dart_assets
issue_tracker: https://github.com/trillionclues/dart_assets/issues
documentation: https://github.com/trillionclues/dart_assets#readme

environment:
  sdk: ^3.0.0

dependencies:
  args: ^2.4.0
  watcher: ^1.1.0
  path: ^1.8.3
  yaml: ^3.1.2
  yaml_edit: ^2.1.1
  dart_style: ^2.3.4
  image: ^4.1.3
  mason_logger: ^0.2.11

dev_dependencies:
  test: ^1.24.0
  mocktail: ^1.0.0
  lints: ^3.0.0

executables:
  dart_assets:
```

### 2. README.md

**Minimum sections:**
- Title and description
- Features
- Installation
- Quick start
- Usage examples
- Contributing
- License

**Example README.md:**
```markdown
# dart_assets

Professional asset management for Flutter projects.

## Features

✅ Auto-update pubspec.yaml when assets change  
✅ Generate type-safe Dart code for asset references  
✅ Optimize images for production  
✅ Find unused assets  
✅ Watch mode for development  

## Installation

\`\`\`bash
dart pub global activate dart_assets
\`\`\`

## Quick Start

\`\`\`bash
# In your Flutter project
dart_assets watch
\`\`\`

## Usage

### Watch Mode
\`\`\`bash
dart_assets watch
\`\`\`

### Generate Code
\`\`\`bash
dart_assets gen
\`\`\`

### Optimize Images
\`\`\`bash
dart_assets optimize
\`\`\`

## Documentation

See [docs/](docs/) for detailed documentation.

## Contributing

Pull requests welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
```

### 3. CHANGELOG.md
```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-02-14

### Added
- Watch mode for automatic asset management
- Code generation for type-safe asset references
- Image optimization (PNG, JPEG, WebP)
- Unused asset detection
- pubspec.yaml auto-update

### Changed
- Initial release

### Fixed
- N/A
```

### 4. LICENSE

**MIT License (Recommended):**
```
MIT License

Copyright (c) 2025 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Publishing Process

### 1. Validate Package
```bash
# Check package structure
dart pub publish --dry-run
```

**Expected output:**
```
Package validation found the following warnings:
  * line 1, column 1 of pubspec.yaml: "repository" field is recommended.

Publishing dart_assets 1.0.0 to https://pub.dev:
  .dart_tool/
  .gitignore
  CHANGELOG.md
  LICENSE
  README.md
  bin/dart_assets.dart
  lib/dart_assets.dart
  lib/src/...
  pubspec.yaml
  test/...

Package has 0 warnings.
```

### 2. Run Final Checks
```bash
# Format code
dart format .

# Analyze
dart analyze

# Run tests
dart test

# Check for outdated dependencies
dart pub outdated
```

### 3. Publish
```bash
# Publish to pub.dev
dart pub publish

# You'll see:
# Publishing dart_assets 1.0.0 to https://pub.dev:
# 
# Package has 0 warnings.
# 
# Do you want to publish dart_assets 1.0.0 to https://pub.dev? (y/N): 

# Type: y
```

### 4. Verify
```bash
# Check package page
open https://pub.dev/packages/dart_assets

# Install globally to test
dart pub global activate dart_assets

# Test installation
dart_assets --version
```

---

## Post-Publishing

### 1. Create GitHub Release
```bash
# Tag was already created during release process
# Create GitHub release from tag

# Or via GitHub CLI:
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes "See CHANGELOG.md for details"
```

### 2. Announce

**Places to announce:**
- [ ] Twitter/X
- [ ] Reddit (r/FlutterDev)
- [ ] Flutter Community Discord
- [ ] Dev.to article
- [ ] Medium article

**Example announcement:**
```
🚀 Just published dart_assets v1.0.0!

A professional asset management CLI for Flutter:
✅ Auto-updates pubspec.yaml
✅ Generates type-safe code
✅ Optimizes images
✅ Finds unused assets

Try it: dart pub global activate dart_assets

https://pub.dev/packages/dart_assets
```

### 3. Monitor

**First 48 hours:**
- [ ] Check pub.dev points score
- [ ] Monitor GitHub issues
- [ ] Respond to questions
- [ ] Fix any critical bugs immediately

---

## Versioning Strategy

### Semantic Versioning

**MAJOR.MINOR.PATCH**

**MAJOR (1.0.0 → 2.0.0):**
- Breaking API changes
- Removed features
- Major architecture changes

**Example:**
```yaml
# v1.x - CLI arguments
dart_assets gen --output lib/assets.dart

# v2.0 - Breaking change (different flag name)
dart_assets gen --out lib/assets.dart
```

**MINOR (1.0.0 → 1.1.0):**
- New features (backward compatible)
- New commands
- Deprecations (without removal)

**Example:**
```bash
# v1.0 - watch and gen commands
# v1.1 - add optimize command (backward compatible)
dart_assets optimize
```

**PATCH (1.0.0 → 1.0.1):**
- Bug fixes
- Security patches
- Documentation updates
- Performance improvements

### Pre-Release Versions

**Alpha:**
```yaml
version: 1.1.0-alpha.1
```
```bash
dart pub publish

# Users install:
dart pub global activate dart_assets --version 1.1.0-alpha.1
```

**Beta:**
```yaml
version: 1.1.0-beta.1
```

**Release Candidate:**
```yaml
version: 1.1.0-rc.1
```

---

## Continuous Deployment

### GitHub Actions

**.github/workflows/publish.yml:**
```yaml
name: Publish to pub.dev

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable
      
      - name: Install dependencies
        run: dart pub get
      
      - name: Format code
        run: dart format --set-exit-if-changed .
      
      - name: Analyze code
        run: dart analyze --fatal-infos
      
      - name: Run tests
        run: dart test
      
      - name: Publish (dry run)
        run: dart pub publish --dry-run
      
      - name: Publish to pub.dev
        uses: k-paxian/dart-package-publisher@v1.5.1
        with:
          credentialJson: ${{ secrets.PUB_DEV_CREDENTIALS }}
          flutter: false
          skipTests: true
```

### Setup Credentials
```bash
# 1. Get credentials
dart pub token add https://pub.dev

# 2. Credentials saved to:
# ~/.pub-cache/credentials.json

# 3. Add to GitHub Secrets:
# Settings → Secrets → New repository secret
# Name: PUB_DEV_CREDENTIALS
# Value: <paste credentials.json content>
```

---

## Maintenance

### Updating Dependencies
```bash
# Check for updates
dart pub outdated

# Update
dart pub upgrade

# Test after updating
dart test

# Commit
git add pubspec.yaml pubspec.lock
git commit -m "chore: update dependencies"
```

### Deprecation Strategy

**Example: Deprecating a command**

**v1.5.0:**
```dart
@Deprecated('Use `gen` command instead. Will be removed in v2.0.0')
class GenerateCommand extends Command {
  // Implementation
}
```

**Documentation:**
```markdown
## Deprecation Notice

The `generate` command is deprecated and will be removed in v2.0.0.
Use `gen` command instead:

\`\`\`bash
# Old (deprecated)
dart_assets generate

# New
dart_assets gen
\`\`\`
```

**v2.0.0:**
```dart
// Remove deprecated command entirely
```

---

## pub.dev Optimization

### 1. Package Score

pub.dev scores packages on:
- **Follow Dart file conventions** (25 points)
- **Provide documentation** (10 points)
- **Support multiple platforms** (20 points)
- **Pass static analysis** (30 points)
- **Support up-to-date dependencies** (10 points)
- **Support null safety** (5 points)

**Target:** 130+ points (out of 140)

### 2. README Optimization

**Include:**
- Clear description (first 200 chars matter!)
- Badges (build status, coverage, pub version)
- GIF/video demo
- Code examples
- Installation instructions
- Links to documentation

**Example badges:**
```markdown
[![pub package](https://img.shields.io/pub/v/dart_assets.svg)](https://pub.dev/packages/dart_assets)
[![Build Status](https://github.com/user/dart_assets/workflows/test/badge.svg)](https://github.com/user/dart_assets/actions)
[![Coverage](https://codecov.io/gh/user/dart_assets/branch/main/graph/badge.svg)](https://codecov.io/gh/user/dart_assets)
```

### 3. Documentation

**Add example/ folder:**
```
example/
├── README.md
├── pubspec.yaml
└── dart_assets_example.dart
```

**example/dart_assets_example.dart:**
```dart
/// Example usage of dart_assets package
import 'package:dart_assets/dart_assets.dart';

void main() async {
  // Example 1: Generate assets
  final generator = CodeGenerator(projectRoot: Directory.current);
  await generator.generate();
  
  // Example 2: Optimize images
  final optimizer = ImageOptimizer();
  await optimizer.optimizeAll(Directory('assets'));
}
```

---

## Rollback Procedure

### Deprecate Version
```bash
# Mark version as discontinued
dart pub admin discontinue dart_assets:1.2.0
```

**Users will see:**
```
Package dart_assets 1.2.0 is discontinued.
Consider using version 1.2.1 instead.
```

### Unpublish (within 7 days)
```bash
# Only possible within 7 days of publishing
# Contact pub.dev support
# Email: pub-dev@googlegroups.com
```

**Note:** After 7 days, you can only discontinue, not unpublish.

---

## Troubleshooting

### "Package name already taken"
```bash
# Check if available
dart pub get

# If taken, choose alternative:
# dart_assets → dart_asset_manager
# dart_assets → assets_generator_dart
```

### "Version already exists"
```bash
# Increment version
# pubspec.yaml: 1.0.0 → 1.0.1

# Publish again
dart pub publish
```

### "Package validation failed"
```bash
# Read error message carefully
dart pub publish --dry-run

# Common issues:
# - Missing description
# - Description too short (<60 chars)
# - Missing repository field
# - Invalid version format
```

---

## Best Practices

### 1. Version Bump Checklist

Before publishing:
- [ ] Update version in pubspec.yaml
- [ ] Update CHANGELOG.md
- [ ] Run `dart pub publish --dry-run`
- [ ] Run all tests
- [ ] Update README if needed
- [ ] Create git tag
- [ ] Publish
- [ ] Verify on pub.dev

### 2. Backward Compatibility
```dart
// GOOD - Backward compatible
class CodeGenerator {
  // Old method still works
  Future<void> generate({String? outputPath}) async {
    // New parameter with default
  }
}

// BAD - Breaking change
class CodeGenerator {
  // Removed outputPath parameter entirely
  Future<void> generate() async { }
}
```

### 3. Communication

**Before major version:**
- Announce breaking changes on GitHub
- Give users time to migrate (1-2 months)
- Provide migration guide
- Respond to questions

**Example migration guide:**
```markdown
# Migrating from v1.x to v2.0

## Breaking Changes

### 1. Command renamed
\`\`\`bash
# v1.x
dart_assets generate

# v2.0
dart_assets gen
\`\`\`

### 2. Output path changed
\`\`\`dart
// v1.x
lib/assets.dart

// v2.0
lib/gen/assets.dart
\`\`\`

## Migration Steps

1. Update commands in scripts
2. Update import paths
3. Run `dart_assets gen`
```

---

## Resources

- [pub.dev Publishing Guide](https://dart.dev/tools/pub/publishing)
- [Package Layout Conventions](https://dart.dev/tools/pub/package-layout)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)