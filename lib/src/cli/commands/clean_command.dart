import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../../analyzer/unused_analyzer.dart';
import '../../parser/pubspec_parser.dart';
import '../../parser/pubspec_updater.dart';
import '../../utils/path_utils.dart';

// remove unused assets
class CleanCommand extends Command<void> {
  final Logger logger;

  CleanCommand({required this.logger}) {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project root.',
        defaultsTo: '.',
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Skip confirmation prompt.',
        defaultsTo: false,
      );
  }

  @override
  String get name => 'clean';

  @override
  String get description => 'Remove unused assets from the project';

  @override
  Future<void> run() async {
    final projectPath = argResults?['path'] as String? ?? '.';
    final projectRoot = Directory(projectPath).absolute;
    final force = argResults?['force'] as bool? ?? false;

    final resolvedRoot = PathUtils.findProjectRoot(projectRoot);
    if (resolvedRoot == null) {
      logger.err('No pubspec.yaml found in $projectPath or parent dirs.');
      return;
    }

    final progress = logger.progress('Scanning for unused assets');

    try {
      final pubspecFile = File('${resolvedRoot.path}/pubspec.yaml');
      final parser = PubspecParser(pubspecFile);
      final declaredAssets = await parser.getAssets();

      if (declaredAssets.isEmpty) {
        progress.complete('No assets declared in pubspec.yaml.');
        return;
      }

      final analyzer = UnusedAssetAnalyzer(projectRoot: resolvedRoot);
      final unused = await analyzer.findUnusedAssets(declaredAssets);

      if (unused.isEmpty) {
        progress.complete('No unused assets found');
        return;
      }

      progress.complete('Found ${unused.length} unused assets');

      logger.info('');
      for (final asset in unused) {
        logger.warn(asset);
      }
      logger.info('');

      // confirm deletion
      if (!force) {
        final confirm = logger.confirm(
          'Delete ${unused.length} unused assets?',
        );
        if (!confirm) {
          logger.info('Cancelled.');
          return;
        }
      }

      // delete files and update pubspec
      final updater = PubspecUpdater(pubspecFile);
      var deletedCount = 0;

      for (final asset in unused) {
        final file = File('${resolvedRoot.path}/$asset');
        if (file.existsSync()) {
          file.deleteSync();
          deletedCount++;
        }
        await updater.removeAsset(asset);
      }

      logger.success(
        'Removed $deletedCount files and updated pubspec.yaml',
      );
    } catch (e) {
      progress.fail('$e');
    }
  }
}
