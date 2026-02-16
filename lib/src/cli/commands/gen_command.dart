import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../../generator/code_generator.dart';
import '../../models/config.dart';
import '../../utils/path_utils.dart';

// generate type-safe Dart code for asset references
class GenCommand extends Command<void> {
  final Logger logger;

  GenCommand({required this.logger}) {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Path to the Flutter project root.',
      defaultsTo: '.',
    );
  }

  @override
  String get name => 'gen';

  @override
  String get description => 'Generate type-safe Dart code for asset references';

  @override
  Future<void> run() async {
    final projectPath = argResults?['path'] as String? ?? '.';
    final projectRoot = Directory(projectPath).absolute;

    final resolvedRoot = PathUtils.findProjectRoot(projectRoot);
    if (resolvedRoot == null) {
      logger.err('No pubspec.yaml found in $projectPath or parent dirs.');
      return;
    }

    final config = await DartAssetsConfig.load(resolvedRoot);
    final progress = logger.progress('Generating asset code');

    try {
      final generator = CodeGenerator(
        projectRoot: resolvedRoot,
        config: config.generate,
        logger: logger,
      );

      await generator.generate();
      progress.complete('Generated ${config.generate.output}');
    } catch (e) {
      progress.fail('$e');
    }
  }
}
