# TESTING STRATEGY

## Overview

Comprehensive testing ensures `dart_assets` works reliably across different Flutter projects, platforms, and edge cases.

---

## Testing Stack

### Core Testing Tools

| Tool | Purpose | Version |
|------|---------|---------|
| **test** | Unit & integration tests | ^1.24.0 |
| **mocktail** | Mocking | ^1.0.0 |
| **path** | Path testing utilities | ^1.8.3 |
| **coverage** | Code coverage | ^1.7.0 |

### Installation
```yaml
# pubspec.yaml
dev_dependencies:
  test: ^1.24.0
  mocktail: ^1.0.0
  coverage: ^1.7.0
```

---

## Test Organization
```
test/
├── unit/                           # Unit tests (isolated)
│   ├── cli/
│   │   └── commands/
│   │       ├── watch_command_test.dart
│   │       ├── gen_command_test.dart
│   │       └── optimize_command_test.dart
│   ├── watcher/
│   │   ├── asset_watcher_test.dart
│   │   ├── debouncer_test.dart
│   │   └── file_filter_test.dart
│   ├── parser/
│   │   ├── pubspec_parser_test.dart
│   │   ├── pubspec_updater_test.dart
│   │   └── naming_converter_test.dart
│   ├── generator/
│   │   ├── code_generator_test.dart
│   │   ├── asset_scanner_test.dart
│   │   └── metadata_extractor_test.dart
│   ├── optimizer/
│   │   ├── png_optimizer_test.dart
│   │   ├── jpeg_optimizer_test.dart
│   │   └── webp_converter_test.dart
│   └── analyzer/
│       ├── usage_analyzer_test.dart
│       └── code_scanner_test.dart
│
├── integration/                    # Integration tests (multiple modules)
│   ├── watch_mode_test.dart
│   ├── full_workflow_test.dart
│   ├── pubspec_generation_test.dart
│   └── optimization_workflow_test.dart
│
├── e2e/                           # End-to-end tests (real projects)
│   ├── real_project_test.dart
│   └── cli_integration_test.dart
│
├── fixtures/                      # Test data
│   ├── test_project/             # Minimal Flutter project
│   │   ├── pubspec.yaml
│   │   ├── lib/
│   │   │   └── main.dart
│   │   └── assets/
│   │       └── images/
│   │           └── logo.png
│   ├── test_assets/              # Sample assets
│   │   ├── valid_png.png
│   │   ├── valid_jpg.jpg
│   │   ├── large_image.png
│   │   └── invalid_image.txt
│   └── pubspec_samples/          # Sample pubspec files
│       ├── minimal.yaml
│       ├── with_assets.yaml
│       └── malformed.yaml
│
└── helpers/                       # Test utilities
    ├── test_project_builder.dart
    ├── asset_generator.dart
    └── matchers.dart
```

---

## Unit Tests

### Testing Debouncer
```dart
// test/unit/watcher/debouncer_test.dart
import 'package:test/test.dart';
import 'package:dart_assets/src/watcher/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('should delay execution', () async {
      var executed = false;
      final debouncer = Debouncer(duration: Duration(milliseconds: 100));
      
      debouncer.call(() => executed = true);
      
      // Should not execute immediately
      expect(executed, false);
      
      // Wait for debounce duration
      await Future.delayed(Duration(milliseconds: 150));
      
      // Now should be executed
      expect(executed, true);
    });
    
    test('should cancel previous calls', () async {
      var callCount = 0;
      final debouncer = Debouncer(duration: Duration(milliseconds: 100));
      
      // Call multiple times rapidly
      for (var i = 0; i < 5; i++) {
        debouncer.call(() => callCount++);
        await Future.delayed(Duration(milliseconds: 20));
      }
      
      // Wait for last call
      await Future.delayed(Duration(milliseconds: 150));
      
      // Should only execute last call
      expect(callCount, 1);
    });
    
    test('should allow execution after timer completes', () async {
      var callCount = 0;
      final debouncer = Debouncer(duration: Duration(milliseconds: 50));
      
      // First call
      debouncer.call(() => callCount++);
      await Future.delayed(Duration(milliseconds: 100));
      expect(callCount, 1);
      
      // Second call (after first completed)
      debouncer.call(() => callCount++);
      await Future.delayed(Duration(milliseconds: 100));
      expect(callCount, 2);
    });
    
    test('should dispose properly', () {
      final debouncer = Debouncer(duration: Duration(milliseconds: 100));
      
      debouncer.call(() {});
      debouncer.dispose();
      
      // Should not crash
      expect(true, true);
    });
  });
}
```

---

### Testing Naming Converter
```dart
// test/unit/parser/naming_converter_test.dart
import 'package:test/test.dart';
import 'package:dart_assets/src/generator/naming_converter.dart';

void main() {
  group('NamingConverter', () {
    group('toValidIdentifier', () {
      test('should convert simple names', () {
        expect(NamingConverter.toValidIdentifier('logo'), 'logo');
        expect(NamingConverter.toValidIdentifier('background'), 'background');
      });
      
      test('should remove file extensions', () {
        expect(NamingConverter.toValidIdentifier('logo.png'), 'logo');
        expect(NamingConverter.toValidIdentifier('icon.svg'), 'icon');
      });
      
      test('should convert to camelCase', () {
        expect(
          NamingConverter.toValidIdentifier('app-icon'),
          'appIcon',
        );
        expect(
          NamingConverter.toValidIdentifier('user_profile'),
          'userProfile',
        );
        expect(
          NamingConverter.toValidIdentifier('my image file'),
          'myImageFile',
        );
      });
      
      test('should handle numbers at start', () {
        expect(
          NamingConverter.toValidIdentifier('2x-logo'),
          '_2xLogo',
        );
        expect(
          NamingConverter.toValidIdentifier('3d-icon'),
          '_3dIcon',
        );
      });
      
      test('should replace invalid characters', () {
        expect(
          NamingConverter.toValidIdentifier('my-logo!'),
          'myLogo',
        );
        expect(
          NamingConverter.toValidIdentifier('icon@2x'),
          'icon2x',
        );
      });
      
      test('should handle Dart keywords', () {
        // Keywords should be handled by generator, not converter
        expect(NamingConverter.toValidIdentifier('class'), 'class');
        expect(NamingConverter.toValidIdentifier('new'), 'new');
      });
      
      test('should handle edge cases', () {
        expect(NamingConverter.toValidIdentifier(''), '');
        expect(NamingConverter.toValidIdentifier('___'), '');
        expect(NamingConverter.toValidIdentifier('...'), '');
      });
    });
    
    group('toPascalCase', () {
      test('should convert to PascalCase', () {
        expect(NamingConverter.toPascalCase('images'), 'Images');
        expect(NamingConverter.toPascalCase('user-profile'), 'UserProfile');
        expect(NamingConverter.toPascalCase('app_icons'), 'AppIcons');
      });
    });
  });
}
```

---

### Testing Pubspec Parser
```dart
// test/unit/parser/pubspec_parser_test.dart
import 'dart:io';
import 'package:test/test.dart';
import 'package:dart_assets/src/parser/pubspec_parser.dart';

void main() {
  group('PubspecParser', () {
    late Directory tempDir;
    late File pubspecFile;
    
    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('test_');
      pubspecFile = File('${tempDir.path}/pubspec.yaml');
    });
    
    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });
    
    test('should parse valid pubspec', () async {
      pubspecFile.writeAsStringSync('''
name: test_app
version: 1.0.0

flutter:
  assets:
    - assets/images/logo.png
    - assets/fonts/Roboto.ttf
''');
      
      final parser = PubspecParser(pubspecFile);
      final assets = await parser.getAssets();
      
      expect(assets.length, 2);
      expect(assets[0], 'assets/images/logo.png');
      expect(assets[1], 'assets/fonts/Roboto.ttf');
    });
    
    test('should handle empty assets list', () async {
      pubspecFile.writeAsStringSync('''
name: test_app

flutter:
  assets: []
''');
      
      final parser = PubspecParser(pubspecFile);
      final assets = await parser.getAssets();
      
      expect(assets, isEmpty);
    });
    
    test('should handle missing flutter section', () async {
      pubspecFile.writeAsStringSync('''
name: test_app
version: 1.0.0
''');
      
      final parser = PubspecParser(pubspecFile);
      final assets = await parser.getAssets();
      
      expect(assets, isEmpty);
    });
    
    test('should handle directory paths', () async {
      pubspecFile.writeAsStringSync('''
name: test_app

flutter:
  assets:
    - assets/images/
    - assets/fonts/
''');
      
      final parser = PubspecParser(pubspecFile);
      final assets = await parser.getAssets();
      
      expect(assets.length, 2);
      expect(assets[0], 'assets/images/');
      expect(assets[1], 'assets/fonts/');
    });
    
    test('should throw on malformed YAML', () {
      pubspecFile.writeAsStringSync('''
name: test_app
flutter:
  assets:
    - invalid
      yaml
''');
      
      final parser = PubspecParser(pubspecFile);
      
      expect(
        () => parser.parse(),
        throwsA(isA<InvalidPubspecError>()),
      );
    });
  });
}
```

---

### Testing with Mocks
```dart
// test/unit/watcher/asset_watcher_test.dart
import 'dart:io';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dart_assets/src/watcher/asset_watcher.dart';

// Mock classes
class MockPubspecUpdater extends Mock implements PubspecUpdater {}
class MockCodeGenerator extends Mock implements CodeGenerator {}

void main() {
  group('AssetWatcher', () {
    late MockPubspecUpdater mockUpdater;
    late MockCodeGenerator mockGenerator;
    
    setUp(() {
      mockUpdater = MockPubspecUpdater();
      mockGenerator = MockCodeGenerator();
      
      // Setup default stubs
      when(() => mockUpdater.addAsset(any())).thenAnswer((_) async {});
      when(() => mockUpdater.removeAsset(any())).thenAnswer((_) async {});
      when(() => mockGenerator.generate()).thenAnswer((_) async {});
    });
    
    test('should call updater when file added', () async {
      final watcher = AssetWatcher(
        projectRoot: Directory.current,
        updater: mockUpdater,
        generator: mockGenerator,
      );
      
      // Simulate file add
      await watcher.handleAdd('assets/images/logo.png');
      
      // Verify updater was called
      verify(() => mockUpdater.addAsset('assets/images/logo.png')).called(1);
      verify(() => mockGenerator.generate()).called(1);
    });
    
    test('should call updater when file removed', () async {
      final watcher = AssetWatcher(
        projectRoot: Directory.current,
        updater: mockUpdater,
        generator: mockGenerator,
      );
      
      await watcher.handleRemove('assets/images/logo.png');
      
      verify(() => mockUpdater.removeAsset('assets/images/logo.png')).called(1);
      verify(() => mockGenerator.generate()).called(1);
    });
    
    test('should not process ignored files', () async {
      final watcher = AssetWatcher(
        projectRoot: Directory.current,
        updater: mockUpdater,
        generator: mockGenerator,
      );
      
      await watcher.handleAdd('assets/.DS_Store');
      
      // Should not call updater for ignored files
      verifyNever(() => mockUpdater.addAsset(any()));
      verifyNever(() => mockGenerator.generate());
    });
  });
}
```

---

## Integration Tests

### Full Workflow Test
```dart
// test/integration/full_workflow_test.dart
import 'dart:io';
import 'package:test/test.dart';
import 'package:dart_assets/src/watcher/asset_watcher.dart';
import 'package:dart_assets/src/generator/code_generator.dart';
import 'package:dart_assets/src/parser/pubspec_updater.dart';

void main() {
  group('Full Workflow Integration', () {
    late Directory testProject;
    late Directory assetsDir;
    late File pubspecFile;
    
    setUp(() {
      // Create test project
      testProject = Directory.systemTemp.createTempSync('test_project_');
      assetsDir = Directory('${testProject.path}/assets/images')
        ..createSync(recursive: true);
      
      pubspecFile = File('${testProject.path}/pubspec.yaml');
      pubspecFile.writeAsStringSync('''
name: test_app
version: 1.0.0

flutter:
  uses-material-design: true
  assets: []
''');
    });
    
    tearDown(() {
      testProject.deleteSync(recursive: true);
    });
    
    test('should handle complete workflow', () async {
      // 1. Add an asset file
      final logoFile = File('${assetsDir.path}/logo.png');
      logoFile.writeAsBytesSync(_createMinimalPng());
      
      // 2. Update pubspec
      final updater = PubspecUpdater(pubspecFile);
      await updater.addAsset('assets/images/logo.png');
      
      // 3. Generate code
      final generator = CodeGenerator(projectRoot: testProject);
      await generator.generate();
      
      // 4. Verify pubspec updated
      final pubspecContent = await pubspecFile.readAsString();
      expect(pubspecContent, contains('assets/images/logo.png'));
      
      // 5. Verify code generated
      final generatedFile = File('${testProject.path}/lib/gen/assets.dart');
      expect(generatedFile.existsSync(), true);
      
      final generatedContent = await generatedFile.readAsString();
      expect(generatedContent, contains('class Assets'));
      expect(generatedContent, contains('static const String logo'));
      expect(generatedContent, contains('assets/images/logo.png'));
    });
    
    test('should handle multiple assets', () async {
      // Add multiple files
      File('${assetsDir.path}/logo.png').writeAsBytesSync(_createMinimalPng());
      File('${assetsDir.path}/icon.png').writeAsBytesSync(_createMinimalPng());
      File('${assetsDir.path}/background.jpg')
          .writeAsBytesSync(_createMinimalJpeg());
      
      // Update and generate
      final updater = PubspecUpdater(pubspecFile);
      await updater.addAsset('assets/images/logo.png');
      await updater.addAsset('assets/images/icon.png');
      await updater.addAsset('assets/images/background.jpg');
      
      final generator = CodeGenerator(projectRoot: testProject);
      await generator.generate();
      
      // Verify
      final generatedFile = File('${testProject.path}/lib/gen/assets.dart');
      final content = await generatedFile.readAsString();
      
      expect(content, contains('logo'));
      expect(content, contains('icon'));
      expect(content, contains('background'));
    });
    
    test('should handle file deletion', () async {
      // Add file
      final logoFile = File('${assetsDir.path}/logo.png');
      logoFile.writeAsBytesSync(_createMinimalPng());
      
      final updater = PubspecUpdater(pubspecFile);
      await updater.addAsset('assets/images/logo.png');
      
      // Delete file
      await updater.removeAsset('assets/images/logo.png');
      
      // Verify removed from pubspec
      final pubspecContent = await pubspecFile.readAsString();
      expect(pubspecContent, isNot(contains('assets/images/logo.png')));
    });
  });
}

// Helper to create minimal PNG
List<int> _createMinimalPng() {
  // Minimal 1x1 PNG
  return [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 dimensions
    0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
    0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
    0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
    0x00, 0x03, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D,
    0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, // IEND chunk
    0x44, 0xAE, 0x42, 0x60, 0x82,
  ];
}

List<int> _createMinimalJpeg() {
  // Minimal JPEG
  return [
    0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46,
    0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01,
    0x00, 0x01, 0x00, 0x00, 0xFF, 0xD9,
  ];
}
```

---

## End-to-End Tests

### Real Project Test
```dart
// test/e2e/real_project_test.dart
import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('E2E: Real Project', () {
    late Directory testProject;
    
    setUp(() async {
      testProject = Directory.systemTemp.createTempSync('e2e_test_');
      
      // Create a real Flutter project structure
      await _createFlutterProject(testProject);
    });
    
    tearDown(() {
      testProject.deleteSync(recursive: true);
    });
    
    test('should work with real Flutter project', () async {
      // Run dart_assets gen command
      final result = await Process.run(
        'dart',
        [
          'run',
          'dart_assets',
          'gen',
        ],
        workingDirectory: testProject.path,
      );
      
      expect(result.exitCode, 0);
      
      // Verify generated file exists
      final generatedFile = File('${testProject.path}/lib/gen/assets.dart');
      expect(generatedFile.existsSync(), true);
      
      // Verify it's valid Dart code
      final analyzeResult = await Process.run(
        'dart',
        ['analyze', generatedFile.path],
      );
      
      expect(analyzeResult.exitCode, 0);
    });
  });
}

Future<void> _createFlutterProject(Directory dir) async {
  // Create pubspec.yaml
  File('${dir.path}/pubspec.yaml').writeAsStringSync('''
name: test_app
description: Test Flutter app
version: 1.0.0+1

environment:
  sdk: ^3.0.0

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/images/
''');
  
  // Create lib/main.dart
  final libDir = Directory('${dir.path}/lib')..createSync();
  File('${libDir.path}/main.dart').writeAsStringSync('''
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold());
  }
}
''');
  
  // Create assets
  final assetsDir = Directory('${dir.path}/assets/images')
    ..createSync(recursive: true);
  
  File('${assetsDir.path}/logo.png').writeAsBytesSync([0, 0, 0, 0]);
}
```

---

## Test Helpers

### Test Project Builder
```dart
// test/helpers/test_project_builder.dart
import 'dart:io';

class TestProjectBuilder {
  late Directory root;
  late File pubspecFile;
  
  Future<void> create() async {
    root = Directory.systemTemp.createTempSync('test_project_');
    pubspecFile = File('${root.path}/pubspec.yaml');
    
    await _createMinimalPubspec();
  }
  
  Future<void> dispose() async {
    await root.delete(recursive: true);
  }
  
  Future<void> addAsset(String path, List<int> bytes) async {
    final file = File('${root.path}/$path');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
  }
  
  Future<void> _createMinimalPubspec() async {
    await pubspecFile.writeAsString('''
name: test_app
version: 1.0.0

flutter:
  assets: []
''');
  }
}

// Usage:
void main() {
  group('My Test', () {
    late TestProjectBuilder project;
    
    setUp(() async {
      project = TestProjectBuilder();
      await project.create();
    });
    
    tearDown(() async {
      await project.dispose();
    });
    
    test('example', () async {
      await project.addAsset('assets/logo.png', [0, 0, 0, 0]);
      // ... test logic
    });
  });
}
```

---

### Custom Matchers
```dart
// test/helpers/matchers.dart
import 'package:test/test.dart';

/// Matcher for valid Dart identifiers
Matcher isValidDartIdentifier() => _IsValidDartIdentifier();

class _IsValidDartIdentifier extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! String) return false;
    
    // Must not be empty
    if (item.isEmpty) return false;
    
    // Must not start with number
    if (RegExp(r'^\d').hasMatch(item)) return false;
    
    // Must only contain valid characters
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(item)) {
      return false;
    }
    
    return true;
  }
  
  @override
  Description describe(Description description) {
    return description.add('a valid Dart identifier');
  }
}

/// Matcher for valid asset paths
Matcher isValidAssetPath() => _IsValidAssetPath();

class _IsValidAssetPath extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! String) return false;
    
    // Must not be absolute
    if (item.startsWith('/')) return false;
    
    // Must not have parent references
    if (item.contains('..')) return false;
    
    // Should start with assets/
    if (!item.startsWith('assets/')) return false;
    
    return true;
  }
  
  @override
  Description describe(Description description) {
    return description.add('a valid asset path');
  }
}

// Usage:
test('should generate valid identifiers', () {
  final name = NamingConverter.toValidIdentifier('logo');
  expect(name, isValidDartIdentifier());
});

test('should create valid asset paths', () {
  final path = 'assets/images/logo.png';
  expect(path, isValidAssetPath());
});
```

---

## Coverage

### Running Coverage
```bash
# Generate coverage
dart test --coverage=coverage

# Convert to LCOV format
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

### Coverage Goals
```
Target Coverage:
- Overall: 90%+
- Critical paths: 95%+
- CLI commands: 85%+
- Utilities: 95%+
```

### GitHub Actions
```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable
      
      - name: Install dependencies
        run: dart pub get
      
      - name: Run tests
        run: dart test
      
      - name: Generate coverage
        run: |
          dart test --coverage=coverage
          dart pub global activate coverage
          dart pub global run coverage:format_coverage \
            --lcov \
            --in=coverage \
            --out=coverage/lcov.info \
            --report-on=lib
      
      - name: Upload to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

---

## Best Practices

### 1. Test One Thing Per Test
```dart
// ✅ GOOD
test('should add asset to pubspec', () async {
  await updater.addAsset('assets/logo.png');
  final assets = await parser.getAssets();
  expect(assets, contains('assets/logo.png'));
});

test('should not add duplicate asset', () async {
  await updater.addAsset('assets/logo.png');
  await updater.addAsset('assets/logo.png');
  final assets = await parser.getAssets();
  expect(assets.where((a) => a == 'assets/logo.png').length, 1);
});

// BAD - testing multiple things
test('should handle assets correctly', () async {
  await updater.addAsset('assets/logo.png');
  await updater.addAsset('assets/icon.png');
  await updater.removeAsset('assets/logo.png');
  // Too many things tested
});
```

### 2. Use Descriptive Test Names
```dart
// GOOD
test('should convert snake_case to camelCase', () { });
test('should throw InvalidPubspecError on malformed YAML', () { });
test('should preserve comments when updating pubspec', () { });

// BAD
test('naming works', () { });
test('error handling', () { });
test('test1', () { });
```

### 3. Clean Up Resources
```dart
// GOOD
group('My Tests', () {
  late Directory tempDir;
  
  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('test_');
  });
  
  tearDown() {
    tempDir.deleteSync(recursive: true);
  };
  
  test('example', () {
    // Use tempDir
  });
});
```

### 4. Test Edge Cases
```dart
test('should handle edge cases', () {
  expect(converter.toValidIdentifier(''), '');
  expect(converter.toValidIdentifier('___'), '');
  expect(converter.toValidIdentifier('123'), '_123');
  expect(converter.toValidIdentifier('class'), 'class'); // Keyword
});
```

---

## Running Tests
```bash
# All tests
dart test

# Specific file
dart test test/unit/parser/naming_converter_test.dart

# Specific test
dart test --name "should convert to camelCase"

# Watch mode
dart test --watch

# Verbose
dart test --reporter expanded

# Parallel
dart test --concurrency=4
```