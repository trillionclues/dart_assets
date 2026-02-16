# PUBSPEC PARSING & MANIPULATION

## Overview

The `pubspec.yaml` file is the heart of Flutter project configuration. This document explains how to safely read, modify, and write pubspec.yaml while preserving formatting and comments.

---

## Understanding pubspec.yaml Structure

### Basic Structure
```yaml
name: my_app
description: A Flutter application
version: 1.0.0+1

environment:
  sdk: ^3.0.0
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/fonts/
```

### Assets Section

Flutter supports two formats for assets:

**Format 1: Directory paths (recommended)**
```yaml
flutter:
  assets:
    - assets/images/      # All files in directory
    - assets/fonts/
```

**Format 2: Individual files**
```yaml
flutter:
  assets:
    - assets/images/logo.png
    - assets/images/background.jpg
    - assets/fonts/Roboto-Regular.ttf
```

**Mixed approach:**
```yaml
flutter:
  assets:
    - assets/images/      # Directory
    - assets/special/icon.svg  # Individual file
```

---

## Reading pubspec.yaml

### Simple Reading
```dart
// lib/src/parser/pubspec_parser.dart
import 'dart:io';
import 'package:yaml/yaml.dart';

class PubspecParser {
  final File pubspecFile;
  
  PubspecParser(this.pubspecFile);
  
  /// Read and parse pubspec.yaml
  Future<YamlMap> parse() async {
    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content);
    
    if (yaml is! YamlMap) {
      throw InvalidPubspecError('pubspec.yaml is not a valid map');
    }
    
    return yaml;
  }
  
  /// Get asset list
  Future<List<String>> getAssets() async {
    final yaml = await parse();
    
    try {
      final flutter = yaml['flutter'];
      if (flutter == null) return [];
      
      final assets = flutter['assets'];
      if (assets == null) return [];
      
      if (assets is YamlList) {
        return assets.map((e) => e.toString()).toList();
      }
      
      return [];
    } catch (e) {
      throw InvalidPubspecError('Failed to parse assets: $e');
    }
  }
  
  /// Check if asset exists
  Future<bool> hasAsset(String assetPath) async {
    final assets = await getAssets();
    return assets.contains(assetPath);
  }
}
```

---

## Modifying pubspec.yaml

### The Challenge: Preserving Formatting

**Problem:** Standard YAML libraries (like `yaml`) can only **read** YAML. When you parse and re-serialize, you lose:
- Comments
- Custom indentation
- Key ordering
- Empty lines

**Example of what NOT to do:**
```dart
// ❌ BAD - Destroys formatting
final yaml = loadYaml(content);
yaml['flutter']['assets'].add('assets/new.png');
final newContent = yaml.toString(); // This doesn't work!
```

**Solution:** Use `yaml_edit` package

### Using yaml_edit Package
```dart
// lib/src/parser/pubspec_updater.dart
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class PubspecUpdater {
  final File pubspecFile;
  
  PubspecUpdater(this.pubspecFile);
  
  /// Add asset to pubspec.yaml
  Future<void> addAsset(String assetPath) async {
    // Read current content
    final content = await pubspecFile.readAsString();
    
    // Create editor
    final editor = YamlEditor(content);
    
    // Parse to check current state
    final yaml = loadYaml(content) as YamlMap;
    
    // Get current assets
    final currentAssets = _getAssetList(yaml);
    
    // Check if already exists
    if (currentAssets.contains(assetPath)) {
      return; // Already in pubspec
    }
    
    // Ensure flutter section exists
    if (!yaml.containsKey('flutter')) {
      editor.update(['flutter'], {});
    }
    
    // Ensure assets list exists
    if (yaml['flutter'] == null || yaml['flutter']['assets'] == null) {
      editor.update(['flutter', 'assets'], []);
    }
    
    // Add asset to end of list
    final newIndex = currentAssets.length;
    editor.update(['flutter', 'assets', newIndex], assetPath);
    
    // Write back
    await pubspecFile.writeAsString(editor.toString());
  }
  
  /// Remove asset from pubspec.yaml
  Future<void> removeAsset(String assetPath) async {
    final content = await pubspecFile.readAsString();
    final editor = YamlEditor(content);
    final yaml = loadYaml(content) as YamlMap;
    
    final currentAssets = _getAssetList(yaml);
    
    // Find index
    final index = currentAssets.indexOf(assetPath);
    if (index == -1) {
      return; // Not in pubspec
    }
    
    // Remove from list
    editor.remove(['flutter', 'assets', index]);
    
    await pubspecFile.writeAsString(editor.toString());
  }
  
  List<String> _getAssetList(YamlMap yaml) {
    try {
      final flutter = yaml['flutter'];
      if (flutter == null) return [];
      
      final assets = flutter['assets'];
      if (assets == null) return [];
      
      if (assets is YamlList) {
        return assets.map((e) => e.toString()).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}
```

### How yaml_edit Works

**Before modification:**
```yaml
flutter:
  uses-material-design: true
  
  # My custom assets
  assets:
    - assets/images/logo.png
    - assets/fonts/Roboto.ttf
```

**After adding `assets/images/new.png`:**
```yaml
flutter:
  uses-material-design: true
  
  # My custom assets  ← Comment preserved!
  assets:
    - assets/images/logo.png
    - assets/fonts/Roboto.ttf
    - assets/images/new.png  ← Added here
```

**yaml_edit preserves:**
- ✅ Comments
- ✅ Indentation
- ✅ Key ordering
- ✅ Empty lines
- ✅ String formatting (single vs double quotes)

---

## Advanced Operations

### 1. Bulk Add Assets
```dart
Future<void> addAssets(List<String> assetPaths) async {
  final content = await pubspecFile.readAsString();
  final editor = YamlEditor(content);
  final yaml = loadYaml(content) as YamlMap;
  
  final currentAssets = _getAssetList(yaml);
  
  // Filter out already existing
  final newAssets = assetPaths
      .where((path) => !currentAssets.contains(path))
      .toList();
  
  if (newAssets.isEmpty) return;
  
  // Add all at once
  var index = currentAssets.length;
  for (final asset in newAssets) {
    editor.update(['flutter', 'assets', index++], asset);
  }
  
  await pubspecFile.writeAsString(editor.toString());
}
```

### 2. Organize Assets by Type
```dart
Future<void> organizeAssets() async {
  final content = await pubspecFile.readAsString();
  final editor = YamlEditor(content);
  final yaml = loadYaml(content) as YamlMap;
  
  final currentAssets = _getAssetList(yaml);
  
  // Group by type
  final images = currentAssets.where((a) => _isImage(a)).toList();
  final fonts = currentAssets.where((a) => _isFont(a)).toList();
  final other = currentAssets.where((a) => !_isImage(a) && !_isFont(a)).toList();
  
  // Sort each group
  images.sort();
  fonts.sort();
  other.sort();
  
  // Combine: images, fonts, other
  final organized = [...images, ...fonts, ...other];
  
  // Replace entire assets list
  editor.update(['flutter', 'assets'], organized);
  
  await pubspecFile.writeAsString(editor.toString());
}
```

### 3. Convert to Directory Format
```dart
Future<void> convertToDirectoryFormat() async {
  final content = await pubspecFile.readAsString();
  final editor = YamlEditor(content);
  final yaml = loadYaml(content) as YamlMap;
  
  final currentAssets = _getAssetList(yaml);
  
  // Find unique directories
  final directories = <String>{};
  for (final asset in currentAssets) {
    final dir = _getDirectory(asset);
    if (dir != null) {
      directories.add('$dir/');
    }
  }
  
  // Replace with directories
  editor.update(['flutter', 'assets'], directories.toList());
  
  await pubspecFile.writeAsString(editor.toString());
}

String? _getDirectory(String assetPath) {
  final parts = assetPath.split('/');
  if (parts.length <= 1) return null;
  
  // Remove filename
  parts.removeLast();
  
  return parts.join('/');
}
```

**Example transformation:**

**Before:**
```yaml
assets:
  - assets/images/logo.png
  - assets/images/icon.png
  - assets/images/background.jpg
  - assets/fonts/Roboto-Regular.ttf
  - assets/fonts/Roboto-Bold.ttf
```

**After:**
```yaml
assets:
  - assets/images/
  - assets/fonts/
```

---

## Edge Cases & Error Handling

### 1. Missing Sections
```dart
Future<void> ensureAssetSection() async {
  final content = await pubspecFile.readAsString();
  final editor = YamlEditor(content);
  final yaml = loadYaml(content) as YamlMap;
  
  // Ensure 'flutter' exists
  if (!yaml.containsKey('flutter')) {
    editor.update(['flutter'], {
      'uses-material-design': true,
      'assets': [],
    });
  } else if (yaml['flutter']['assets'] == null) {
    // 'flutter' exists but no 'assets'
    editor.update(['flutter', 'assets'], []);
  }
  
  await pubspecFile.writeAsString(editor.toString());
}
```

### 2. Malformed YAML
```dart
Future<YamlMap> parseSafely() async {
  try {
    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content);
    
    if (yaml is! YamlMap) {
      throw InvalidPubspecError('Root element is not a map');
    }
    
    return yaml;
  } on YamlException catch (e) {
    throw InvalidPubspecError(
      'Failed to parse pubspec.yaml:\n'
      'Line ${e.span?.start.line}: ${e.message}\n\n'
      'Please fix the syntax error and try again.'
    );
  } on FileSystemException catch (e) {
    throw PubspecNotFoundError(
      'Could not read pubspec.yaml: ${e.message}'
    );
  }
}
```

### 3. Concurrent Modifications
```dart
class PubspecUpdater {
  final File pubspecFile;
  final _lock = Lock(); // From synchronized package
  
  Future<void> addAsset(String assetPath) async {
    // Prevent concurrent modifications
    await _lock.synchronized(() async {
      final content = await pubspecFile.readAsString();
      // ... rest of logic
    });
  }
}
```

**Why:** If watch mode detects multiple files quickly, you could have race conditions.

---

## Validation

### 1. Validate Asset Paths
```dart
class AssetValidator {
  final Directory projectRoot;
  
  AssetValidator(this.projectRoot);
  
  /// Validate asset path format
  bool isValidAssetPath(String path) {
    // Must be relative
    if (path.startsWith('/') || path.startsWith('..')) {
      return false;
    }
    
    // Must start with known directories
    const validPrefixes = ['assets/', 'lib/', 'packages/'];
    if (!validPrefixes.any((prefix) => path.startsWith(prefix))) {
      return false;
    }
    
    // Check file exists
    final file = File('${projectRoot.path}/$path');
    return file.existsSync();
  }
  
  /// Find broken asset references
  Future<List<String>> findBrokenAssets() async {
    final parser = PubspecParser(pubspecFile);
    final assets = await parser.getAssets();
    
    final broken = <String>[];
    
    for (final asset in assets) {
      // Directory reference
      if (asset.endsWith('/')) {
        final dir = Directory('${projectRoot.path}/$asset');
        if (!dir.existsSync()) {
          broken.add(asset);
        }
      } else {
        // File reference
        final file = File('${projectRoot.path}/$asset');
        if (!file.existsSync()) {
          broken.add(asset);
        }
      }
    }
    
    return broken;
  }
}
```

### 2. Validate Pubspec Structure
```dart
class PubspecStructureValidator {
  Future<List<String>> validate(File pubspecFile) async {
    final issues = <String>[];
    
    try {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      
      // Check required fields
      if (!yaml.containsKey('name')) {
        issues.add('Missing required field: name');
      }
      
      if (!yaml.containsKey('description')) {
        issues.add('Missing recommended field: description');
      }
      
      if (!yaml.containsKey('version')) {
        issues.add('Missing recommended field: version');
      }
      
      // Check Flutter section
      if (yaml.containsKey('flutter')) {
        final flutter = yaml['flutter'];
        
        if (flutter is YamlMap) {
          // Check assets format
          if (flutter.containsKey('assets')) {
            final assets = flutter['assets'];
            
            if (assets is! YamlList) {
              issues.add('flutter.assets must be a list');
            }
          }
        } else {
          issues.add('flutter section must be a map');
        }
      }
      
      return issues;
    } catch (e) {
      issues.add('Failed to parse: $e');
      return issues;
    }
  }
}
```

---

## Testing

### Unit Tests
```dart
// test/unit/parser/pubspec_updater_test.dart
import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('PubspecUpdater', () {
    late Directory tempDir;
    late File pubspecFile;
    late PubspecUpdater updater;
    
    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('test_');
      pubspecFile = File('${tempDir.path}/pubspec.yaml');
      
      // Create minimal pubspec
      pubspecFile.writeAsStringSync('''
name: test_app
version: 1.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/logo.png
''');
      
      updater = PubspecUpdater(pubspecFile);
    });
    
    tearDown() {
      tempDir.deleteSync(recursive: true);
    });
    
    test('should add asset', () async {
      await updater.addAsset('assets/images/new.png');
      
      final content = await pubspecFile.readAsString();
      expect(content, contains('assets/images/new.png'));
      expect(content, contains('assets/images/logo.png')); // Old still there
    });
    
    test('should not add duplicate', () async {
      await updater.addAsset('assets/images/logo.png'); // Already exists
      
      final content = await pubspecFile.readAsString();
      final occurrences = 'assets/images/logo.png'.allMatches(content).length;
      
      expect(occurrences, 1); // Only one occurrence
    });
    
    test('should remove asset', () async {
      await updater.removeAsset('assets/images/logo.png');
      
      final content = await pubspecFile.readAsString();
      expect(content, isNot(contains('assets/images/logo.png')));
    });
    
    test('should preserve comments', () async {
      // Add comment
      pubspecFile.writeAsStringSync('''
name: test_app

flutter:
  # Important assets
  assets:
    - assets/images/logo.png
''');
      
      await updater.addAsset('assets/images/new.png');
      
      final content = await pubspecFile.readAsString();
      expect(content, contains('# Important assets'));
    });
  });
}
```

---

## Best Practices

### 1. Always Validate Before Writing
```dart
Future<void> addAsset(String assetPath) async {
  // Validate first
  if (!_isValidAssetPath(assetPath)) {
    throw InvalidAssetPathError(assetPath);
  }
  
  // Then proceed
  // ...
}
```

### 2. Create Backups
```dart
Future<void> updateWithBackup(void Function(YamlEditor) updateFn) async {
  // Create backup
  final backupFile = File('${pubspecFile.path}.backup');
  await pubspecFile.copy(backupFile.path);
  
  try {
    final content = await pubspecFile.readAsString();
    final editor = YamlEditor(content);
    
    // Apply updates
    updateFn(editor);
    
    // Write
    await pubspecFile.writeAsString(editor.toString());
    
    // Delete backup on success
    await backupFile.delete();
  } catch (e) {
    // Restore backup on error
    await backupFile.copy(pubspecFile.path);
    await backupFile.delete();
    rethrow;
  }
}
```

### 3. Use Relative Paths
```dart
String toRelativePath(String absolutePath) {
  final projectPath = projectRoot.path;
  
  if (absolutePath.startsWith(projectPath)) {
    return absolutePath.substring(projectPath.length + 1);
  }
  
  return absolutePath;
}
```

### 4. Handle Different Asset Formats
```dart
Future<bool> hasAssetCoverage(String assetPath) async {
  final assets = await getAssets();
  
  for (final asset in assets) {
    // Check directory format
    if (asset.endsWith('/')) {
      if (assetPath.startsWith(asset)) {
        return true; // Covered by directory
      }
    }
    
    // Check exact match
    if (asset == assetPath) {
      return true;
    }
  }
  
  return false;
}
```

---

## Common Pitfalls

### 1. Modifying Without yaml_edit
```dart
// BAD
final yaml = loadYaml(content);
yaml['flutter']['assets'].add('new.png'); // Doesn't work!

// GOOD
final editor = YamlEditor(content);
editor.update(['flutter', 'assets', index], 'new.png');
```

### 2. Not Handling Missing Sections
```dart
// BAD
editor.update(['flutter', 'assets', 0], 'asset.png');
// Crashes if flutter.assets doesn't exist

// GOOD
await ensureAssetSection();
editor.update(['flutter', 'assets', 0], 'asset.png');
```

### 3. Using Absolute Paths
```dart
// BAD
addAsset('/Users/dev/project/assets/logo.png');

// GOOD
addAsset('assets/logo.png');
```