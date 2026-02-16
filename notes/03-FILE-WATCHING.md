# FILE WATCHING - Deep Dive

## Overview

File watching is the core feature of `dart_assets`. This document explains how to efficiently monitor file system changes in Dart.

---

## File System Events

### Event Types

The `watcher` package provides three event types:
```dart
enum ChangeType {
  ADD,     // New file created
  MODIFY,  // Existing file changed
  REMOVE,  // File deleted
}
```

### Event Object
```dart
class WatchEvent {
  final ChangeType type;  // What happened
  final String path;      // Full path to file
  
  WatchEvent(this.type, this.path);
}
```

---

## Implementation Strategies

### Strategy 1: Single Directory Watcher (Recommended for v1.0)

**Best for:** Simple projects with one assets folder
```dart
// lib/src/watcher/asset_watcher.dart
import 'dart:async';
import 'dart:io';
import 'package:watcher/watcher.dart';

class AssetWatcher {
  final Directory projectRoot;
  DirectoryWatcher? _watcher;
  StreamSubscription<WatchEvent>? _subscription;
  
  AssetWatcher({required this.projectRoot});
  
  Future<void> start() async {
    final assetsDir = Directory('${projectRoot.path}/assets');
    
    if (!assetsDir.existsSync()) {
      throw AssetDirectoryNotFoundError(assetsDir.path);
    }
    
    // Create watcher for entire assets directory
    _watcher = DirectoryWatcher(assetsDir.path);
    
    // Listen to events
    _subscription = _watcher!.events.listen(
      _handleEvent,
      onError: _handleError,
      cancelOnError: false,
    );
    
    print('👀 Watching: ${assetsDir.path}\n');
  }
  
  void _handleEvent(WatchEvent event) {
    if (!_shouldProcess(event.path)) return;
    
    switch (event.type) {
      case ChangeType.ADD:
        _onAdd(event.path);
        break;
      case ChangeType.MODIFY:
        _onModify(event.path);
        break;
      case ChangeType.REMOVE:
        _onRemove(event.path);
        break;
    }
  }
  
  bool _shouldProcess(String path) {
    // Ignore hidden files
    if (path.contains('/.')) return false;
    
    // Ignore temp files
    if (path.endsWith('~') || path.endsWith('.tmp')) return false;
    
    // Only process asset files
    return _isSupportedAsset(path);
  }
  
  bool _isSupportedAsset(String path) {
    const extensions = [
      // Images
      '.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg', '.bmp',
      // Fonts
      '.ttf', '.otf', '.woff', '.woff2',
      // Videos
      '.mp4', '.mov', '.avi',
      // Data
      '.json', '.xml',
    ];
    
    return extensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
  
  void _onAdd(String path) {
    print('[${_timestamp()}] + $path');
    // Handle add logic
  }
  
  void _onModify(String path) {
    print('[${_timestamp()}] ~ $path');
    // Handle modify logic
  }
  
  void _onRemove(String path) {
    print('[${_timestamp()}] - $path');
    // Handle remove logic
  }
  
  void _handleError(dynamic error) {
    print('⚠️  Watcher error: $error');
  }
  
  String _timestamp() {
    return DateTime.now().toIso8601String().substring(11, 19);
  }
  
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _watcher = null;
  }
}
```

---

### Strategy 2: Multiple Watchers (Advanced)

**Best for:** Large projects with organized asset structure
```dart
class MultiAssetWatcher {
  final Directory projectRoot;
  final List<DirectoryWatcher> _watchers = [];
  final List<StreamSubscription> _subscriptions = [];
  
  Future<void> start() async {
    // Watch specific subdirectories
    final subDirs = [
      'assets/images',
      'assets/fonts',
      'assets/videos',
      'assets/data',
    ];
    
    for (final subDir in subDirs) {
      final dir = Directory('${projectRoot.path}/$subDir');
      
      if (!dir.existsSync()) continue;
      
      final watcher = DirectoryWatcher(dir.path);
      _watchers.add(watcher);
      
      final subscription = watcher.events.listen(
        (event) => _handleEvent(event, subDir),
      );
      _subscriptions.add(subscription);
      
      print('👀 Watching: $subDir');
    }
  }
  
  Future<void> stop() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _watchers.clear();
  }
}
```

**Pros:**
- More targeted watching
- Can apply different rules per directory
- Better performance for large projects

**Cons:**
- More complex setup
- Need to manage multiple watchers

---

## Debouncing

### Why Debounce?

Text editors often trigger multiple events for a single save:
```
[14:32:15.100] MODIFY assets/logo.png
[14:32:15.150] MODIFY assets/logo.png
[14:32:15.200] MODIFY assets/logo.png
```

Without debouncing, you'd process the same file 3 times!

### Debouncer Implementation
```dart
// lib/src/watcher/debouncer.dart
import 'dart:async';

class Debouncer {
  final Duration duration;
  Timer? _timer;
  
  Debouncer({required this.duration});
  
  /// Delays execution until no more calls for [duration]
  void call(void Function() action) {
    // Cancel existing timer
    _timer?.cancel();
    
    // Start new timer
    _timer = Timer(duration, action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}

// Usage:
final debouncer = Debouncer(duration: Duration(milliseconds: 500));

void _handleEvent(WatchEvent event) {
  debouncer.call(() {
    // This will only execute once, 500ms after last event
    _processEvent(event);
  });
}
```

### Advanced: Per-File Debouncing

For better control, debounce per file instead of globally:
```dart
class PerFileDebouncer {
  final Duration duration;
  final Map<String, Timer> _timers = {};
  
  PerFileDebouncer({required this.duration});
  
  void call(String filePath, void Function() action) {
    // Cancel existing timer for this file
    _timers[filePath]?.cancel();
    
    // Start new timer
    _timers[filePath] = Timer(duration, () {
      action();
      _timers.remove(filePath);
    });
  }
  
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}

// Usage:
final debouncer = PerFileDebouncer(duration: Duration(milliseconds: 500));

void _handleEvent(WatchEvent event) {
  debouncer.call(event.path, () {
    _processEvent(event);
  });
}
```

**Benefits:**
- Different files can be processed simultaneously
- Only debounces repeated changes to same file
- Better UX for rapid changes to multiple files

---

## File Filters

### Extension-Based Filtering
```dart
class FileFilter {
  static const imageExtensions = [
    '.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg', '.bmp', '.ico',
  ];
  
  static const fontExtensions = [
    '.ttf', '.otf', '.woff', '.woff2',
  ];
  
  static const videoExtensions = [
    '.mp4', '.mov', '.avi', '.mkv', '.webm',
  ];
  
  static const dataExtensions = [
    '.json', '.xml', '.yaml', '.yml', '.csv',
  ];
  
  static bool isImage(String path) {
    return imageExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
  
  static bool isFont(String path) {
    return fontExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
  
  static bool isVideo(String path) {
    return videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
  
  static bool isData(String path) {
    return dataExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
  
  static bool isAsset(String path) {
    return isImage(path) || isFont(path) || isVideo(path) || isData(path);
  }
}
```

### Pattern-Based Filtering
```dart
class PatternFilter {
  // Ignore patterns
  static final ignorePatterns = [
    RegExp(r'/\.[^/]+$'),          // Hidden files
    RegExp(r'~$'),                  // Temp files
    RegExp(r'\.tmp$'),              // Temp files
    RegExp(r'\.DS_Store$'),         // macOS
    RegExp(r'Thumbs\.db$'),         // Windows
    RegExp(r'\.git/'),              // Git directory
    RegExp(r'node_modules/'),       // Node modules
    RegExp(r'\.idea/'),             // IDE
    RegExp(r'\.vscode/'),           // VS Code
  ];
  
  static bool shouldIgnore(String path) {
    return ignorePatterns.any((pattern) => pattern.hasMatch(path));
  }
  
  // Asset patterns
  static bool isInAssetsDirectory(String path, Directory projectRoot) {
    final assetsPath = '${projectRoot.path}/assets/';
    return path.startsWith(assetsPath);
  }
}
```

---

## Event Processing Pipeline

### Complete Pipeline
```dart
class EventProcessor {
  final Debouncer _debouncer;
  final PubspecUpdater _pubspecUpdater;
  final CodeGenerator _codeGenerator;
  
  EventProcessor({
    required Directory projectRoot,
  })  : _debouncer = Debouncer(duration: Duration(milliseconds: 500)),
        _pubspecUpdater = PubspecUpdater(projectRoot: projectRoot),
        _codeGenerator = CodeGenerator(projectRoot: projectRoot);
  
  void process(WatchEvent event) {
    // Step 1: Filter
    if (!_shouldProcess(event)) return;
    
    // Step 2: Debounce
    _debouncer.call(() => _handleEvent(event));
  }
  
  bool _shouldProcess(WatchEvent event) {
    // Check if it's a supported asset
    if (!FileFilter.isAsset(event.path)) return false;
    
    // Check ignore patterns
    if (PatternFilter.shouldIgnore(event.path)) return false;
    
    return true;
  }
  
  Future<void> _handleEvent(WatchEvent event) async {
    try {
      switch (event.type) {
        case ChangeType.ADD:
          await _handleAdd(event.path);
          break;
        case ChangeType.REMOVE:
          await _handleRemove(event.path);
          break;
        case ChangeType.MODIFY:
          await _handleModify(event.path);
          break;
      }
    } catch (e) {
      print('Error processing ${event.path}: $e');
    }
  }
  
  Future<void> _handleAdd(String path) async {
    print('[${_timestamp()}] + $path');
    
    // Update pubspec.yaml
    await _pubspecUpdater.addAsset(path);
    print('  Updated pubspec.yaml');
    
    // Regenerate code
    await _codeGenerator.generate();
    print('  Regenerated assets.dart\n');
  }
  
  Future<void> _handleRemove(String path) async {
    print('[${_timestamp()}] - $path');
    
    await _pubspecUpdater.removeAsset(path);
    print('  Removed from pubspec.yaml');
    
    await _codeGenerator.generate();
    print('  Regenerated assets.dart\n');
  }
  
  Future<void> _handleModify(String path) async {
    print('[${_timestamp()}] ~ $path');
    print('  ℹ️  File modified (no action needed)\n');
    
    // Future: Could trigger re-optimization
  }
  
  String _timestamp() {
    return DateTime.now().toIso8601String().substring(11, 19);
  }
}
```

---

## Platform-Specific Considerations

### macOS

**File limit issue:**
```bash
# Check current limit
launchctl limit maxfiles

# Increase (temporary)
sudo launchctl limit maxfiles 65536 200000

# Permanent: Add to /Library/LaunchDaemons/limit.maxfiles.plist
```

**Recommended limits:**
- Small projects (<1000 files): Default is fine
- Medium projects (1000-5000 files): Increase to 10240
- Large projects (>5000 files): Increase to 65536

### Linux

**inotify limits:**
```bash
# Check current limit
cat /proc/sys/fs/inotify/max_user_watches

# Increase (temporary)
sudo sysctl fs.inotify.max_user_watches=524288

# Permanent: Add to /etc/sysctl.conf
fs.inotify.max_user_watches=524288
```

### Windows

Windows uses `ReadDirectoryChangesW`, which has its own limits:
- Maximum of 64 directory watchers per process
- Buffer overflow if too many changes

**Mitigation:**
```dart
// Use polling fallback on Windows for large projects
DirectoryWatcher watcher;

if (Platform.isWindows) {
  watcher = PollingDirectoryWatcher(path);
} else {
  watcher = DirectoryWatcher(path);
}
```

---

## Error Handling

### Common Errors

**1. Permission Denied**
```dart
try {
  final watcher = DirectoryWatcher(path);
  await for (final event in watcher.events) {
    // Process
  }
} on FileSystemException catch (e) {
  if (e.osError?.errorCode == 13) { // Permission denied
    print('Permission denied: $path');
    print('💡 Run: chmod +r $path');
  }
}
```

**2. Directory Deleted While Watching**
```dart
StreamSubscription? _subscription;

void start() {
  _subscription = watcher.events.listen(
    _handleEvent,
    onError: (error) {
      if (error is FileSystemException) {
        print('⚠️  Directory no longer exists, stopping watcher');
        stop();
      }
    },
    cancelOnError: false, // Continue on errors
  );
}
```

**3. Too Many Open Files**
```dart
try {
  final watcher = DirectoryWatcher(path);
} catch (e) {
  if (e.toString().contains('Too many open files')) {
    print('System file limit reached');
    print('💡 Increase limit: ulimit -n 4096');
    rethrow;
  }
}
```

---

## Performance Optimization

### 1. Batch Updates

Instead of processing each event immediately:
```dart
class BatchProcessor {
  final Duration batchWindow;
  final List<WatchEvent> _pending = [];
  Timer? _timer;
  
  BatchProcessor({this.batchWindow = const Duration(seconds: 1)});
  
  void add(WatchEvent event) {
    _pending.add(event);
    
    _timer?.cancel();
    _timer = Timer(batchWindow, _processBatch);
  }
  
  Future<void> _processBatch() async {
    if (_pending.isEmpty) return;
    
    final events = List<WatchEvent>.from(_pending);
    _pending.clear();
    
    // Group by type
    final added = events.where((e) => e.type == ChangeType.ADD);
    final removed = events.where((e) => e.type == ChangeType.REMOVE);
    
    // Process as batch
    if (added.isNotEmpty) {
      await _processAddBatch(added.map((e) => e.path).toList());
    }
    
    if (removed.isNotEmpty) {
      await _processRemoveBatch(removed.map((e) => e.path).toList());
    }
    
    // Single code generation at the end
    await _generateCode();
  }
}
```

**Benefits:**
- Reduces pubspec.yaml writes
- Single code generation for multiple files
- Better performance for bulk operations (e.g., git checkout)

### 2. Ignore Duplicate Events
```dart
class EventDeduplicator {
  final Map<String, WatchEvent> _lastEvents = {};
  final Duration ttl;
  
  EventDeduplicator({this.ttl = const Duration(milliseconds: 100)});
  
  bool shouldProcess(WatchEvent event) {
    final key = '${event.type}:${event.path}';
    final lastEvent = _lastEvents[key];
    
    if (lastEvent != null) {
      final elapsed = DateTime.now().difference(lastEvent.timestamp);
      if (elapsed < ttl) {
        return false; // Duplicate event
      }
    }
    
    _lastEvents[key] = _TimestampedEvent(event, DateTime.now());
    return true;
  }
}
```

### 3. Lazy File System Operations

Don't read file contents unless necessary:
```dart
Future<void> _handleAdd(String path) async {
  // ✅ GOOD - Only read when needed
  if (FileFilter.isImage(path)) {
    final metadata = await extractImageMetadata(path);
    // Use metadata
  }
  
  // ❌ BAD - Always reading
  final bytes = await File(path).readAsBytes();
}
```

---

## Testing File Watchers

### Unit Test
```dart
// test/unit/watcher/debouncer_test.dart
import 'package:test/test.dart';

void main() {
  group('Debouncer', () {
    test('should delay execution', () async {
      var executed = false;
      final debouncer = Debouncer(duration: Duration(milliseconds: 100));
      
      debouncer.call(() => executed = true);
      
      // Should not execute immediately
      expect(executed, false);
      
      // Wait for debounce
      await Future.delayed(Duration(milliseconds: 150));
      
      expect(executed, true);
    });
    
    test('should cancel previous calls', () async {
      var callCount = 0;
      final debouncer = Debouncer(duration: Duration(milliseconds: 100));
      
      // Call multiple times
      debouncer.call(() => callCount++);
      await Future.delayed(Duration(milliseconds: 50));
      
      debouncer.call(() => callCount++);
      await Future.delayed(Duration(milliseconds: 50));
      
      debouncer.call(() => callCount++);
      
      // Wait for last call
      await Future.delayed(Duration(milliseconds: 150));
      
      // Should only execute last call
      expect(callCount, 1);
    });
  });
}
```

### Integration Test
```dart
// test/integration/watcher_test.dart
import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('AssetWatcher Integration', () {
    late Directory testDir;
    late Directory assetsDir;
    
    setUp(() {
      testDir = Directory.systemTemp.createTempSync('test_');
      assetsDir = Directory('${testDir.path}/assets')
        ..createSync();
    });
    
    tearDown() {
      testDir.deleteSync(recursive: true);
    }
    
    test('should detect new file', () async {
      final events = <WatchEvent>[];
      final watcher = AssetWatcher(projectRoot: testDir);
      
      // Collect events
      watcher.events.listen(events.add);
      
      await watcher.start();
      
      // Add file
      File('${assetsDir.path}/test.png').writeAsBytesSync([]);
      
      // Wait for event
      await Future.delayed(Duration(seconds: 1));
      
      expect(events.length, 1);
      expect(events.first.type, ChangeType.ADD);
      expect(events.first.path, contains('test.png'));
      
      await watcher.stop();
    });
  });
}
```

---

## Best Practices

### 1. Always Clean Up
```dart
class AssetWatcher {
  StreamSubscription? _subscription;
  
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

// Usage:
final watcher = AssetWatcher(projectRoot: dir);
try {
  await watcher.start();
} finally {
  await watcher.stop(); // Always stop
}
```

### 2. Handle Errors Gracefully
```dart
_subscription = watcher.events.listen(
  _handleEvent,
  onError: (error) {
    logger.err('Watcher error: $error');
    // Don't crash, just log
  },
  cancelOnError: false, // Keep watching despite errors
);
```

### 3. Provide User Feedback
```dart
void _handleEvent(WatchEvent event) {
  // Show what's happening
  print('[${_timestamp()}] ${_eventIcon(event.type)} ${event.path}');
  
  // Show progress
  final progress = logger.progress('Updating project');
  try {
    // Do work
    progress.complete('+ Done');
  } catch (e) {
    progress.fail('- Failed: $e');
  }
}

String _eventIcon(ChangeType type) {
  switch (type) {
    case ChangeType.ADD: return '+';
    case ChangeType.MODIFY: return '~';
    case ChangeType.REMOVE: return '-';
  }
}
```

### 4. Test on All Platforms

Different platforms have different file watching implementations:
- **macOS:** FSEvents (fast, efficient)
- **Linux:** inotify (efficient)
- **Windows:** ReadDirectoryChangesW (can be slow)

<!-- test watcher on target platforms! -->