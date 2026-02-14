# DEVELOPMENT GUIDE - Setup, coding standards

## Prerequisites

### Required
- **Dart SDK:** >= 3.0.0
- **Flutter:** >= 3.16.0 (for testing in real Flutter projects)
- **Git:** >= 2.30.0

### Recommended
- **VS Code** with Dart extension
- **Android Studio** or **IntelliJ IDEA** with Dart plugin

---

## Setup Instructions

### 1. Create Project
```bash
# Create Dart CLI package
dart create -t console dart_assets
cd dart_assets

# Project structure:
dart_assets/
├── bin/
│   └── dart_assets.dart    # CLI entry point
├── lib/
│   ├── src/                   # Implementation
│   └── dart_assets.dart    # Public API
├── test/
├── pubspec.yaml
└── README.md
```

### 2. Configure pubspec.yaml
```yaml
name: dart_assets
description: Professional asset management for Flutter projects
version: 1.0.0
repository: https://github.com/trillionclues/dart_assets

environment:
  sdk: ^3.0.0

dependencies:
  # CLI framework
  args: ^2.4.0
  cli_util: ^0.4.0
  io: ^1.0.4
  
  # File watching
  watcher: ^1.1.0
  path: ^1.8.3
  
  # YAML parsing
  yaml: ^3.1.2
  yaml_edit: ^2.1.1
  
  # Code generation
  dart_style: ^2.3.4
  
  # Image processing
  image: ^4.1.3
  
  # Utilities
  mason_logger: ^0.2.11  # Better console output

dev_dependencies:
  lints: ^3.0.0
  test: ^1.24.0
  mocktail: ^1.0.0

executables:
  dart_assets:  # Makes 'dart_assets' command available globally
```

### 3. Install Dependencies
```bash
dart pub get
```

### 4. Activate Locally (for testing)
```bash
# Activate from source
dart pub global activate --source path .

# Now you can run:
dart_assets --version
dart_assets --help
```

---

## Project Structure (Complete)
```
dart_assets/
├── bin/
│   └── dart_assets.dart           # CLI entry point
│
├── lib/
│   ├── src/
│   │   ├── cli/
│   │   │   ├── runner.dart           # Command runner
│   │   │   ├── commands/
│   │   │   │   ├── watch_command.dart
│   │   │   │   ├── gen_command.dart
│   │   │   │   ├── optimize_command.dart
│   │   │   │   ├── unused_command.dart
│   │   │   │   ├── clean_command.dart
│   │   │   │   ├── doctor_command.dart
│   │   │   │   └── check_command.dart
│   │   │   └── ui/
│   │   │       ├── logger.dart       # Console output
│   │   │       └── spinner.dart      # Progress indicators
│   │   │
│   │   ├── watcher/
│   │   │   ├── asset_watcher.dart    # Main watcher
│   │   │   ├── file_event.dart       # Event types
│   │   │   ├── debouncer.dart        # Debounce logic
│   │   │   └── filters.dart          # File filters
│   │   │
│   │   ├── parser/
│   │   │   ├── pubspec_parser.dart   # Read pubspec.yaml
│   │   │   ├── pubspec_updater.dart  # Update pubspec.yaml
│   │   │   └── asset_entry.dart      # Asset model
│   │   │
│   │   ├── generator/
│   │   │   ├── code_generator.dart   # Generate Dart code
│   │   │   ├── asset_scanner.dart    # Scan file system
│   │   │   ├── metadata_extractor.dart
│   │   │   └── templates/
│   │   │       └── assets_template.dart
│   │   │
│   │   ├── optimizer/
│   │   │   ├── image_optimizer.dart  # Optimize images
│   │   │   ├── webp_converter.dart   # PNG/JPEG → WebP
│   │   │   └── size_analyzer.dart    # Check file sizes
│   │   │
│   │   ├── analyzer/
│   │   │   ├── usage_analyzer.dart   # Find unused assets
│   │   │   ├── code_scanner.dart     # Scan Dart files
│   │   │   └── reference_finder.dart # Find asset references
│   │   │
│   │   ├── models/
│   │   │   ├── asset_info.dart       # Asset metadata
│   │   │   ├── project_config.dart   # Config model
│   │   │   └── analysis_result.dart  # Analysis output
│   │   │
│   │   └── utils/
│   │       ├── file_utils.dart       # File operations
│   │       ├── errors.dart           # Custom errors
│   │       └── constants.dart        # Constants
│   │
│   └── dart_assets.dart           # Public API
│
├── test/
│   ├── unit/
│   │   ├── watcher/
│   │   ├── parser/
│   │   ├── generator/
│   │   └── analyzer/
│   ├── integration/
│   └── fixtures/
│       ├── test_project/             # Sample Flutter project
│       └── test_assets/              # Sample assets
│
├── example/
│   └── README.md                      # Usage examples
│
├── docs/                              # Documentation
├── CHANGELOG.md
├── LICENSE
├── README.md
└── pubspec.yaml
```

---

## Development Workflow

### 1. Create Feature Branch
```bash
git checkout -b feature/watch-mode
```

### 2. Implement Feature
```bash
# Edit code
code lib/src/watcher/asset_watcher.dart

# Run locally
dart run bin/dart_assets.dart watch
```

### 3. Run Tests
```bash
# All tests
dart test

# Specific test file
dart test test/unit/watcher/asset_watcher_test.dart

# With coverage
dart test --coverage=coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 4. Format & Lint
```bash
# Format code
dart format .

# Analyze
dart analyze

# Fix issues
dart fix --apply
```

### 5. Test in Real Flutter Project
```bash
# Terminal 1: Activate from source
cd ~/projects/dart_assets
dart pub global activate --source path .

# Terminal 2: Test in Flutter app
cd ~/projects/my_flutter_app
dart_assets watch
```

---

## Coding Standards

### File Naming
- **Dart files:** `snake_case.dart`
- **Test files:** `*_test.dart`
- **Models:** `*_model.dart` or just descriptive name

### Code Style
```dart
// GOOD
class AssetWatcher {
  final Directory projectRoot;
  final Duration debounceDuration;
  
  AssetWatcher({
    required this.projectRoot,
    this.debounceDuration = const Duration(milliseconds: 500),
  });
  
  Future<void> start() async {
    // Implementation
  }
}

// BAD
class assetWatcher {
  var projectRoot;
  var debounceDuration;
  
  assetWatcher(this.projectRoot, this.debounceDuration);
  
  start() {
    // Implementation
  }
}
```

### Error Handling
```dart
// GOOD - Custom exceptions
class AssetDirectoryNotFoundError implements Exception {
  final String path;
  
  AssetDirectoryNotFoundError(this.path);
  
  @override
  String toString() => 'Asset directory not found: $path';
}

throw AssetDirectoryNotFoundError('/path/to/assets');

// BAD - Generic exceptions
throw Exception('Directory not found');
```

### Async/Await
```dart
// GOOD
Future<void> updatePubspec(String assetPath) async {
  final content = await file.readAsString();
  final updated = await processContent(content);
  await file.writeAsString(updated);
}

// BAD - Not handling futures
void updatePubspec(String assetPath) {
  file.readAsString().then((content) {
    processContent(content).then((updated) {
      file.writeAsString(updated);
    });
  });
}
```

### Null Safety
```dart
// GOOD - Explicit null handling
String? findAsset(String name) {
  final asset = assets.firstWhere(
    (a) => a.name == name,
    orElse: () => null,
  );
  return asset?.path;
}

// BAD - Force unwrapping
String findAsset(String name) {
  return assets.firstWhere((a) => a.name == name).path!;
}
```

---

## Debugging

### VS Code Configuration

**.vscode/launch.json:**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run dart_assets",
      "type": "dart",
      "request": "launch",
      "program": "bin/dart_assets.dart",
      "args": ["watch"],
      "cwd": "${workspaceFolder}/example/test_project"
    },
    {
      "name": "Debug Tests",
      "type": "dart",
      "request": "launch",
      "program": "test/"
    }
  ]
}
```

### Logging
```dart
// lib/src/utils/logger.dart
import 'package:mason_logger/mason_logger.dart';

final logger = Logger();

// Usage:
logger.info(' => Updated pubspec.yaml');
logger.warn(' => Large file detected: 5.2 MB');
logger.err(' => Failed to read pubspec.yaml');
logger.detail(' => Debug: Processing ${files.length} files');

// With progress
final progress = logger.progress(' => Optimizing images...');
// ... do work ...
progress.complete(' => Optimized 12 images!');
```

---

## Testing Strategy

### Unit Tests
```dart
// test/unit/watcher/debouncer_test.dart
import 'package:test/test.dart';
import 'package:dart_assets/src/watcher/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('should debounce rapid calls', () async {
      var callCount = 0;
      final debouncer = Debouncer(
        duration: Duration(milliseconds: 100),
      );
      
      // Call 5 times rapidly
      for (var i = 0; i < 5; i++) {
        debouncer.call(() => callCount++);
      }
      
      // Wait for debounce
      await Future.delayed(Duration(milliseconds: 150));
      
      // Should only execute once
      expect(callCount, 1);
    });
  });
}
```

### Integration Tests
```dart
// test/integration/watch_mode_test.dart
import 'dart:io';
import 'package:test/test.dart';
import 'package:dart_assets/src/watcher/asset_watcher.dart';

void main() {
  group('Watch Mode Integration', () {
    late Directory testProject;
    late Directory assetsDir;
    
    setUp(() {
      // Create temp test project
      testProject = Directory.systemTemp.createTempSync('test_project_');
      assetsDir = Directory('${testProject.path}/assets')
        ..createSync(recursive: true);
      
      // Create minimal pubspec.yaml
      File('${testProject.path}/pubspec.yaml').writeAsStringSync('''
name: test_app
version: 1.0.0

flutter:
  assets:
    - assets/
''');
    });
    
    tearDown(() {
      testProject.deleteSync(recursive: true);
    });
    
    test('should detect new asset and update pubspec', () async {
      final watcher = AssetWatcher(projectRoot: testProject);
      
      // Start watcher
      final watcherFuture = watcher.start();
      
      // Wait a bit for watcher to initialize
      await Future.delayed(Duration(milliseconds: 100));
      
      // Add a file
      final testFile = File('${assetsDir.path}/test.png');
      testFile.writeAsBytesSync([0, 0, 0, 0]); // Minimal PNG
      
      // Wait for processing
      await Future.delayed(Duration(seconds: 1));
      
      // Check pubspec was updated
      final pubspec = File('${testProject.path}/pubspec.yaml')
          .readAsStringSync();
      
      expect(pubspec, contains('assets/test.png'));
      
      // Cleanup
      await watcher.stop();
    });
  });
}
```

### Test Fixtures
```
test/fixtures/
├── test_project/
│   ├── pubspec.yaml
│   ├── lib/
│   │   └── main.dart
│   └── assets/
│       ├── images/
│       │   ├── logo.png
│       │   └── background.jpg
│       └── fonts/
│           └── Roboto-Regular.ttf
└── test_assets/
    ├── valid_image.png
    ├── invalid_image.txt
    └── large_image.png (>1MB)
```

---

## Publishing to pub.dev

### 1. Prepare for Publishing
```bash
# Update version
# Edit pubspec.yaml: version: 1.0.0

# Update CHANGELOG.md
echo "## 1.0.0\n- Initial release" >> CHANGELOG.md

# Format & analyze
dart format .
dart analyze

# Run tests
dart test

# Dry run
dart pub publish --dry-run
```

### 2. Publish
```bash
# Publish to pub.dev
dart pub publish

# Follow prompts
# Confirm: y
```

### 3. Verify
```bash
# Check on pub.dev
open https://pub.dev/packages/dart_assets

# Install globally
dart pub global activate dart_assets

# Test
dart_assets --version
```

---

## Versioning (Semantic Versioning)

**Format:** MAJOR.MINOR.PATCH

- **PATCH (1.0.0 → 1.0.1):** Bug fixes
- **MINOR (1.0.0 → 1.1.0):** New features (backward compatible)
- **MAJOR (1.0.0 → 2.0.0):** Breaking changes

**Example progression:**
```
1.0.0 - Initial release
1.0.1 - Fix pubspec parsing bug
1.1.0 - Add optimize command
1.2.0 - Add unused command
2.0.0 - Breaking: Change generated code structure
```

---

## Common Development Tasks

### Add New Command
```bash
# 1. Create command file
touch lib/src/cli/commands/new_command.dart

# 2. Implement command
cat > lib/src/cli/commands/new_command.dart << 'EOF'
import 'package:args/command_runner.dart';

class NewCommand extends Command {
  @override
  String get name => 'new';
  
  @override
  String get description => 'Description of new command';
  
  @override
  Future<void> run() async {
    print('Executing new command...');
  }
}
EOF

# 3. Register in runner
# Edit lib/src/cli/runner.dart and add:
# addCommand(NewCommand());

# 4. Test
dart run bin/dart_assets.dart new
```

### Add Dependency
```bash
# Add to pubspec.yaml
dart pub add package_name

# Or dev dependency
dart pub add --dev package_name

# Update
dart pub get
```

### Generate Coverage Report
```bash
# Run tests with coverage
dart test --coverage=coverage

# Convert to HTML
dart pub global activate coverage
dart pub global run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --report-on=lib

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

---

## Troubleshooting

### "Command not found: dart_assets"
```bash
# Check if globally activated
dart pub global list

# If not there, activate
dart pub global activate dart_assets

# Check PATH
echo $PATH | grep ".pub-cache/bin"

# If missing, add to ~/.zshrc or ~/.bashrc:
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### "Version solving failed"
```bash
# Clear cache
dart pub cache clean

# Try again
dart pub get
```

### Tests Failing
```bash
# Run verbose
dart test --reporter expanded

# Run single test
dart test test/unit/specific_test.dart

# Debug test
# Add breakpoint in VS Code and use Debug Tests configuration
```

### File Watcher Not Detecting Changes
```bash
# Check file system limits (macOS/Linux)
# macOS:
sysctl kern.maxfiles
sysctl kern.maxfilesperproc

# Increase if needed:
sudo sysctl -w kern.maxfiles=65536
sudo sysctl -w kern.maxfilesperproc=65536
```

---

## Best Practices

### 1. Always Use Type Annotations
```dart
// ✅ GOOD
final List<String> assets = [];
String getName() => 'asset';

// ❌ BAD
final assets = [];
getName() => 'asset';
```

### 2. Prefer Immutability
```dart
// ✅ GOOD
class AssetInfo {
  final String path;
  final int size;
  
  const AssetInfo({required this.path, required this.size});
}

// ❌ BAD
class AssetInfo {
  String path;
  int size;
}
```

### 3. Use Meaningful Names
```dart
// ✅ GOOD
Future<List<AssetInfo>> scanAssetsDirectory() async { }

// ❌ BAD
Future<List<AssetInfo>> scan() async { }
Future<List<AssetInfo>> doIt() async { }
```

### 4. Document Public APIs
```dart
/// Watches the assets directory for changes and automatically
/// updates pubspec.yaml and generates type-safe code.
///
/// Usage:
/// ```dart
/// final watcher = AssetWatcher(projectRoot: Directory.current);
/// await watcher.start();
/// ```
class AssetWatcher {
  // Implementation
}
```

### 5. Handle Errors Gracefully
```dart
Future<void> readPubspec() async {
  try {
    final content = await file.readAsString();
    return parsePubspec(content);
  } on FileSystemException catch (e) {
    throw PubspecNotFoundError('pubspec.yaml not found: ${e.path}');
  } on FormatException catch (e) {
    throw InvalidPubspecError('Invalid YAML: ${e.message}');
  }
}
```