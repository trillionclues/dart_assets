# ARCHITECTURE & SYSTEM DESIGN

## High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                        CLI Layer                            │
│  (Command parsing, user interface, progress indicators)     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    File Watcher Layer                       │
│  (Monitor asset folder, detect add/remove/modify)           │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Pubspec Parser Layer                       │
│  (Read/write pubspec.yaml, validate structure)              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 Code Generator Layer                        │
│  (Generate type-safe Dart code for assets)                  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Optimizer Layer                            │
│  (Compress images, convert formats)                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Analyzer Layer                             │
│  (Find unused assets, detect missing references)            │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. CLI Module (`lib/src/cli/`)

**Responsibilities:**
- Parse command-line arguments
- Display progress/spinners
- Handle user confirmations
- Manage command lifecycle

**Files:**
```
lib/src/cli/
├── runner.dart              # Main CLI runner
├── commands/
│   ├── watch_command.dart   # Watch mode
│   ├── gen_command.dart     # Generate code
│   ├── optimize_command.dart
│   ├── unused_command.dart
│   ├── clean_command.dart
│   ├── doctor_command.dart
│   └── check_command.dart
└── ui/
    ├── spinner.dart         # Loading indicators
    ├── logger.dart          # Colored output
    └── prompts.dart         # User confirmations
```

**Key Dependencies:**
- `args` - Command-line parsing
- `cli_util` - CLI utilities
- `io` - Process exit codes

**Example Command Structure:**
```dart
// lib/src/cli/commands/watch_command.dart
import 'package:args/command_runner.dart';

class WatchCommand extends Command {
  @override
  String get name => 'watch';
  
  @override
  String get description => 'Watch assets folder for changes';
  
  @override
  Future<void> run() async {
    final watcher = AssetWatcher(projectRoot: Directory.current);
    await watcher.start();
  }
}
```

---

### 2. File Watcher Module (`lib/src/watcher/`)

**Responsibilities:**
- Monitor asset folder for file system events
- Debounce rapid changes
- Filter relevant file types
- Emit events for processing

**Files:**
```
lib/src/watcher/
├── asset_watcher.dart       # Main watcher
├── file_event.dart          # Event types
├── debouncer.dart           # Debounce logic
└── filters.dart             # File type filters
```

**Key Dependencies:**
- `watcher` - File system monitoring
- `path` - Path manipulation

**Implementation:**
```dart
// lib/src/watcher/asset_watcher.dart
import 'dart:async';
import 'dart:io';
import 'package:watcher/watcher.dart';

class AssetWatcher {
  final Directory projectRoot;
  final Duration debounceDuration;
  
  late final DirectoryWatcher _watcher;
  late final Debouncer _debouncer;
  
  AssetWatcher({
    required this.projectRoot,
    this.debounceDuration = const Duration(milliseconds: 500),
  }) {
    _debouncer = Debouncer(duration: debounceDuration);
  }
  
  Future<void> start() async {
    final assetDir = Directory('${projectRoot.path}/assets');
    
    if (!assetDir.existsSync()) {
      throw AssetDirectoryNotFoundError();
    }
    
    _watcher = DirectoryWatcher(assetDir.path);
    
    print('👀 Watching: ${assetDir.path}\n');
    print('Watching for changes... (Press Ctrl+C to stop)\n');
    
    await for (final event in _watcher.events) {
      if (_shouldProcess(event)) {
        _debouncer.call(() => _handleEvent(event));
      }
    }
  }
  
  bool _shouldProcess(WatchEvent event) {
    final path = event.path;
    
    // Ignore hidden files, temp files
    if (path.contains('/.') || path.endsWith('~')) {
      return false;
    }
    
    // Only process supported asset types
    final supportedExtensions = [
      '.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg', '.avif',
      '.ttf', '.otf', '.woff', '.woff2',
      '.mp4', '.mov',
      '.json', '.yaml',
    ];
    
    return supportedExtensions.any((ext) => path.endsWith(ext));
  }
  
  Future<void> _handleEvent(WatchEvent event) async {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    
    switch (event.type) {
      case ChangeType.ADD:
        print('[$timestamp] + ${event.path}');
        await _handleAdd(event.path);
        break;
        
      case ChangeType.REMOVE:
        print('[$timestamp] - ${event.path}');
        await _handleRemove(event.path);
        break;
        
      case ChangeType.MODIFY:
        print('[$timestamp] ~ ${event.path}');
        await _handleModify(event.path);
        break;
    }
  }
  
  Future<void> _handleAdd(String filePath) async {
    // Update pubspec.yaml
    final updater = PubspecUpdater(projectRoot: projectRoot);
    await updater.addAsset(filePath);
    print('=> Updated pubspec.yaml');
    
    // Regenerate code
    final generator = CodeGenerator(projectRoot: projectRoot);
    await generator.generate();
    print('=> Regenerated assets.dart\n');
  }
  
  Future<void> _handleRemove(String filePath) async {
    final updater = PubspecUpdater(projectRoot: projectRoot);
    await updater.removeAsset(filePath);
    print('=> Removed from pubspec.yaml');
    
    final generator = CodeGenerator(projectRoot: projectRoot);
    await generator.generate();
    print('=> Regenerated assets.dart\n');
  }
  
  Future<void> _handleModify(String filePath) async {
    // For now, just log (could trigger re-optimization)
    // could use any AI tool to analyze the file and 
    // suggest changes or optimization
    print('⚠️  Modified (no action needed)\n');
  }
}
```

**Debouncer Implementation:**
```dart
// lib/src/watcher/debouncer.dart
import 'dart:async';

class Debouncer {
  final Duration duration;
  Timer? _timer;
  
  Debouncer({required this.duration});
  
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}
```

**Why Debouncing:**
- File saves can trigger multiple events
- Prevents redundant pubspec updates
- Reduces CPU usage

---

### 3. Pubspec Parser Module (`lib/src/parser/`)

**Responsibilities:**
- Read pubspec.yaml
- Parse YAML structure
- Add/remove asset entries
- Preserve formatting and comments
- Write changes back safely

**Files:**
```
lib/src/parser/
├── pubspec_parser.dart      # YAML parser
├── pubspec_updater.dart     # Update logic
└── asset_entry.dart         # Asset representation
```

**Key Dependencies:**
- `yaml` - YAML parsing
- `yaml_edit` - Preserve formatting when editing

**Implementation:**
```dart
// lib/src/parser/pubspec_updater.dart
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class PubspecUpdater {
  final Directory projectRoot;
  late final File _pubspecFile;
  
  PubspecUpdater({required this.projectRoot}) {
    _pubspecFile = File('${projectRoot.path}/pubspec.yaml');
  }
  
  Future<void> addAsset(String assetPath) async {
    // Convert absolute path to relative
    final relativePath = _toRelativePath(assetPath);
    
    // Read current pubspec
    final content = await _pubspecFile.readAsString();
    final editor = YamlEditor(content);
    
    // Get current assets
    final yaml = loadYaml(content);
    final currentAssets = _getAssetList(yaml);
    
    // Check if already exists
    if (currentAssets.contains(relativePath)) {
      return;
    }
    
    // Add to assets list
    final assetIndex = currentAssets.length;
    editor.update(
      ['flutter', 'assets', assetIndex],
      relativePath,
    );
    
    // Write back
    await _pubspecFile.writeAsString(editor.toString());
  }
  
  Future<void> removeAsset(String assetPath) async {
    final relativePath = _toRelativePath(assetPath);
    
    final content = await _pubspecFile.readAsString();
    final editor = YamlEditor(content);
    
    final yaml = loadYaml(content);
    final currentAssets = _getAssetList(yaml);
    
    final index = currentAssets.indexOf(relativePath);
    if (index == -1) {
      return; // Not in pubspec
    }
    
    editor.remove(['flutter', 'assets', index]);
    
    await _pubspecFile.writeAsString(editor.toString());
  }
  
  String _toRelativePath(String absolutePath) {
    final projectPath = projectRoot.path;
    return absolutePath.replaceFirst('$projectPath/', '');
  }
  
  List<String> _getAssetList(dynamic yaml) {
    try {
      final flutter = yaml['flutter'];
      if (flutter == null) return [];
      
      final assets = flutter['assets'];
      if (assets == null) return [];
      
      return List<String>.from(assets);
    } catch (e) {
      return [];
    }
  }
}
```

**Preserving Formatting:**
Using `yaml_edit` package ensures:
- Comments are preserved
- Indentation stays consistent
- Custom formatting maintained
- No re-ordering of unrelated keys

---

### 4. Code Generator Module (`lib/src/generator/`)

**Responsibilities:**
- Scan assets folder
- Generate type-safe Dart code
- Create asset metadata
- Format generated code

**Files:**
```
lib/src/generator/
├── code_generator.dart      # Main generator
├── templates/
│   └── assets_template.dart # Code template
├── asset_scanner.dart       # Scan file system
└── metadata_extractor.dart  # Image dimensions, etc.
```

**Key Dependencies:**
- `image` - Extract image metadata
- `dart_style` - Format generated code

**Implementation:**
```dart
// lib/src/generator/code_generator.dart
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:dart_style/dart_style.dart';

class CodeGenerator {
  final Directory projectRoot;
  
  CodeGenerator({required this.projectRoot});
  
  Future<void> generate() async {
    // Scan assets
    final scanner = AssetScanner(projectRoot: projectRoot);
    final assets = await scanner.scan();
    
    // Generate code
    final code = _generateCode(assets);
    
    // Format
    final formatter = DartFormatter();
    final formatted = formatter.format(code);
    
    // Write to file
    final outputFile = File('${projectRoot.path}/lib/gen/assets.dart');
    await outputFile.parent.create(recursive: true);
    await outputFile.writeAsString(formatted);
  }
  
  String _generateCode(List<AssetInfo> assets) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated by dart_assets on ${DateTime.now()}');
    buffer.writeln();
    buffer.writeln('// ignore_for_file: constant_identifier_names');
    buffer.writeln();
    
    // Class definition
    buffer.writeln('class Assets {');
    buffer.writeln('  Assets._();');
    buffer.writeln();
    
    // Group by type
    final images = assets.where((a) => a.isImage).toList();
    final fonts = assets.where((a) => a.isFont).toList();
    
    // Images
    if (images.isNotEmpty) {
      buffer.writeln('  // Images');
      for (final asset in images) {
        final name = _toCamelCase(asset.name);
        buffer.writeln('  static const String $name = \'${asset.path}\';');
      }
      buffer.writeln();
    }
    
    // Fonts
    if (fonts.isNotEmpty) {
      buffer.writeln('  // Fonts');
      for (final asset in fonts) {
        final name = _toCamelCase(asset.name);
        buffer.writeln('  static const String $name = \'${asset.path}\';');
      }
      buffer.writeln();
    }
    
    // All assets list
    buffer.writeln('  // All assets');
    buffer.writeln('  static const List<String> all = [');
    for (final asset in assets) {
      final name = _toCamelCase(asset.name);
      buffer.writeln('    $name,');
    }
    buffer.writeln('  ];');
    
    buffer.writeln('}');
    
    return buffer.toString();
  }
  
  String _toCamelCase(String name) {

    name = name.split('.').first;
    
    final parts = name.split(RegExp(r'[-_\s]'));
    if (parts.isEmpty) return name;
    
    final first = parts.first.toLowerCase();
    final rest = parts.skip(1).map((p) => 
      p[0].toUpperCase() + p.substring(1).toLowerCase()
    );
    
    return [first, ...rest].join();
  }
}
```

---

## How Watch Mode Works with Flutter App

### **Important: They Run Independently**
```
Terminal 1:                    Terminal 2:
┌─────────────────────┐       ┌─────────────────────┐
│ dart_assets watch│  │       │ flutter run        │
│                     │       │                     │
│ Watches assets/     │       │ Runs your app       │
│ Updates pubspec     │       │                     │
│ Generates code      │       │ Hot reload works!   │
└─────────────────────┘       └─────────────────────┘
        ↓                              ↓
    Detects new file                App notices
    Updates pubspec.yaml            pubspec change
    Generates assets.dart           Hot reloads
                                   ✅ New asset available!
```

### **Workflow:**

**Step 1: Start watch mode**
```bash
cd my_flutter_app
dart_assets watch
```

**Step 2: Start Flutter app (separate terminal)**
```bash
flutter run
```

**Step 3: Add an asset**
```bash
# Just drag & drop image into assets/images/
# Or: cp ~/Downloads/logo.png assets/images/
```

**Step 4: Automatic update**
```
👀 Watching: /Users/you/my_app/assets/

[14:32:15] + assets/images/logo.png
✅ Updated pubspec.yaml
✅ Regenerated assets.dart

# Flutter app hot reloads automatically!
# logo.png is now available via Assets.logo
```

### **Why This Works:**

Flutter's hot reload watches `pubspec.yaml`:
- When `dart_assets` updates pubspec
- Flutter detects the change
- Triggers hot reload
- New assets are available immediately

**No restart needed!** ✨

---

### **Alternative: Single Command (Advanced)**

For v2.0, you could integrate into Flutter workflow:
```bash
# This would be future feature
dart_assets dev

# Internally runs:
# 1. dart_assets watch &
# 2. flutter run
```

But for v1.0, **keep separate**. Cleaner, easier to debug.

---

## Performance Considerations

### **File Watching Performance:**
```dart
// Only watch specific directories (any harm in watching entire assets folder?)
final dirs = [
  'assets/images',
  'assets/fonts',
  'assets/videos',
];

// Don't watch entire project (slow)
// ❌ DirectoryWatcher(projectRoot.path)
// ✅ Multiple targeted watchers
```

### **Debounce Settings:**
```dart
// Too short: Multiple updates for single save
Debouncer(duration: Duration(milliseconds: 100))

// Too long: Feels sluggish
Debouncer(duration: Duration(milliseconds: 2000))

// Just right:
Debouncer(duration: Duration(milliseconds: 500))
```

### **Memory Management:**
```dart
class AssetWatcher {
  StreamSubscription? _subscription;
  
  Future<void> start() async {
    _subscription = _watcher.events.listen(_handleEvent);
  }
  
  Future<void> stop() async {
    await _subscription?.cancel();
  }
}
```