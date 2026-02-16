// Watches assets directory for file system changes and triggers
// pubspec updates and code regeneration.

import 'dart:async';
import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

import '../generator/code_generator.dart';
import '../parser/pubspec_updater.dart';
import 'debouncer.dart';
import 'filters.dart';

class AssetWatcher {
  final Directory projectRoot;
  final Duration debounceDuration;
  final Logger logger;
  final PubspecUpdater _updater;
  final CodeGenerator _generator;

  DirectoryWatcher? _watcher;
  StreamSubscription<WatchEvent>? _subscription;
  late final Debouncer _debouncer;

  AssetWatcher({
    required this.projectRoot,
    required this.logger,
    required PubspecUpdater updater,
    required CodeGenerator generator,
    this.debounceDuration = const Duration(milliseconds: 500),
  })  : _updater = updater,
        _generator = generator {
    _debouncer = Debouncer(duration: debounceDuration);
  }

  Future<void> start() async {
    final assetsDir = Directory('${projectRoot.path}/assets');

    if (!assetsDir.existsSync()) {
      throw AssetDirectoryNotFoundError(assetsDir.path);
    }

    _watcher = DirectoryWatcher(assetsDir.path);

    logger.info('👀 Watching: ${assetsDir.path}\n');

    _subscription = _watcher!.events.listen(
      _handleEvent,
      onError: _handleError,
      cancelOnError: false,
    );
  }

  void _handleEvent(WatchEvent event) {
    if (!FileFilter.isAsset(event.path)) return;
    if (PatternFilter.shouldIgnore(event.path)) return;

    _debouncer.call(() => _processEvent(event));
  }

  Future<void> _processEvent(WatchEvent event) async {
    final relativePath = p.relative(event.path, from: projectRoot.path);
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);

    try {
      switch (event.type) {
        case ChangeType.ADD:
          logger.info('[$timestamp] + $relativePath');
          await _updater.addAsset(relativePath);
          logger.success('  ✅ Updated pubspec.yaml');
          await _generator.generate();
          logger.success('  ✅ Regenerated assets.dart');
          break;

        case ChangeType.MODIFY:
          logger.info('[$timestamp] ~ $relativePath');
          // No pubspec change needed for modifications
          break;

        case ChangeType.REMOVE:
          logger.info('[$timestamp] - $relativePath');
          await _updater.removeAsset(relativePath);
          logger.success('  ✅ Updated pubspec.yaml');
          await _generator.generate();
          logger.success('  ✅ Regenerated assets.dart');
          break;
      }
    } catch (e) {
      logger.err('  ❌ Error processing $relativePath: $e');
    }
  }

  void _handleError(dynamic error) {
    logger.err('⚠️  Watcher error: $error');
  }

  Future<void> stop() async {
    _debouncer.dispose();
    await _subscription?.cancel();
    _subscription = null;
    _watcher = null;
    logger.info('\n🛑 Stopped watching.');
  }
}

// exception when assets directory cannot be found.
class AssetDirectoryNotFoundError implements Exception {
  final String path;

  AssetDirectoryNotFoundError(this.path);

  @override
  String toString() => 'Asset directory not found: $path';
}
