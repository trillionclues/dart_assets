import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../../analyzer/unused_analyzer.dart';
import '../../parser/pubspec_parser.dart';
import '../../utils/path_utils.dart';

// detects unused assets
class UnusedCommand extends Command<void> {
  final Logger logger;

  UnusedCommand({required this.logger}) {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Path to the Flutter project root.',
      defaultsTo: '.',
    );
  }

  @override
  String get name => 'unused';

  @override
  String get description => 'Find assets not referenced in any Dart file';

  @override
  Future<void> run() async {
    final projectPath = argResults?['path'] as String? ?? '.';
    final projectRoot = Directory(projectPath).absolute;

    final resolvedRoot = PathUtils.findProjectRoot(projectRoot);
    if (resolvedRoot == null) {
      logger.err('No pubspec.yaml found in $projectPath or parent dirs.');
      return;
    }

    final progress = logger.progress('Scanning for unused assets');

    try {
      final parser = PubspecParser(
        File('${resolvedRoot.path}/pubspec.yaml'),
      );
      final declaredAssets = await parser.getAssets();

      if (declaredAssets.isEmpty) {
        progress.complete('No assets declared in pubspec.yaml.');
        return;
      }

      final analyzer = UnusedAssetAnalyzer(projectRoot: resolvedRoot);
      final unused = await analyzer.findUnusedAssets(declaredAssets);

      if (unused.isEmpty) {
        progress.complete('All ${declaredAssets.length} assets are in use');
        return;
      }

      progress.complete('Found ${unused.length} unused assets');

      logger.info('');
      var totalSize = 0;
      for (final asset in unused) {
        final file = File('${resolvedRoot.path}/$asset');
        final size = file.existsSync() ? file.lengthSync() : 0;
        totalSize += size;
        final sizeStr = _formatBytes(size);
        logger.warn('  $asset — $sizeStr');
      }

      logger.info('');
      logger.info(
          'Found ${unused.length} unused assets (${_formatBytes(totalSize)})');
      logger.info('');
      logger.info("💡 Run 'dart_assets clean' to remove them.");
    } catch (e) {
      progress.fail('$e');
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
