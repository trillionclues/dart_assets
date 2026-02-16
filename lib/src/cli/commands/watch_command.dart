import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../../generator/code_generator.dart';
import '../../models/config.dart';
import '../../parser/pubspec_updater.dart';
import '../../utils/path_utils.dart';
import '../../watcher/asset_watcher.dart';

// watch assets folder for changes and auto-updates changes
class WatchCommand extends Command<void> {
  final Logger logger;

  WatchCommand({required this.logger}) {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Path to the Flutter project root.',
      defaultsTo: '.',
    );
  }

  @override
  String get name => 'watch';

  @override
  String get description => 'Watch assets folder for changes and auto-update';

  @override
  Future<void> run() async {
    final projectPath = argResults?['path'] as String? ?? '.';
    final projectRoot = Directory(projectPath).absolute;

    // Validate project root
    final resolvedRoot = PathUtils.findProjectRoot(projectRoot);
    if (resolvedRoot == null) {
      logger.err('No pubspec.yaml found in $projectPath or parent dirs.');
      return;
    }

    final config = await DartAssetsConfig.load(resolvedRoot);

    final pubspecFile = File('${resolvedRoot.path}/pubspec.yaml');
    final updater = PubspecUpdater(pubspecFile);
    final generator = CodeGenerator(
      projectRoot: resolvedRoot,
      config: config.generate,
      logger: logger,
    );

    // Create and start watcher
    final watcher = AssetWatcher(
      projectRoot: resolvedRoot,
      logger: logger,
      updater: updater,
      generator: generator,
      debounceDuration: Duration(milliseconds: config.watch.debounceMs),
    );

    try {
      await watcher.start();

      // Keep running until SIGINT
      await ProcessSignal.sigint.watch().first;
    } catch (e) {
      logger.err('$e');
    } finally {
      await watcher.stop();
    }
  }
}
