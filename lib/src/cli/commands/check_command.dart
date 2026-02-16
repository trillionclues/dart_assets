import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../../analyzer/missing_analyzer.dart';
import '../../generator/code_generator.dart';
import '../../models/config.dart';
import '../../optimizer/size_validator.dart';
import '../../parser/pubspec_parser.dart';
import '../../utils/path_utils.dart';

class CheckCommand extends Command<void> {
  final Logger logger;

  CheckCommand({required this.logger}) {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Path to the Flutter project root.',
      defaultsTo: '.',
    );
  }

  @override
  String get name => 'check';

  @override
  String get description => 'Validate asset setup (CI-friendly)';

  @override
  Future<void> run() async {
    final projectPath = argResults?['path'] as String? ?? '.';
    final projectRoot = Directory(projectPath).absolute;

    final resolvedRoot = PathUtils.findProjectRoot(projectRoot);
    if (resolvedRoot == null) {
      logger.err('No pubspec.yaml found in $projectPath or parent dirs.');
      exitCode = 1;
      return;
    }

    final config = await DartAssetsConfig.load(resolvedRoot);
    var hasErrors = false;

    logger.info('Checking asset configuration...\n');

    // 1. Check for missing assets (in pubspec but not on disk)
    final parser = PubspecParser(
      File('${resolvedRoot.path}/pubspec.yaml'),
    );
    final declaredAssets = await parser.getAssets();

    final missingAnalyzer = MissingAssetAnalyzer(projectRoot: resolvedRoot);
    final missingAssets =
        await missingAnalyzer.findMissingAssets(declaredAssets);

    if (missingAssets.isEmpty) {
      logger.info('All declared assets exist on disk');
    } else {
      hasErrors = true;
      logger.err(
          '${missingAssets.length} assets in pubspec.yaml not found on disk:');
      for (final asset in missingAssets) {
        logger.err('     - $asset');
      }
    }

    // 2. Check for size violations
    final assetsDir = Directory('${resolvedRoot.path}/assets');
    if (assetsDir.existsSync()) {
      final sizeValidator = SizeValidator(
        maxFileSizeKB: config.optimize.maxFileSizeKb,
      );
      final violations = await sizeValidator.validate(assetsDir);

      if (violations.isEmpty) {
        logger.info('All assets within size limits');
      } else {
        hasErrors = true;
        logger.err(
            '${violations.length} assets exceed ${config.optimize.maxFileSizeKb}KB limit:');
        for (final v in violations) {
          logger.err('     - ${v.path} (${v.humanReadableSize})');
        }
      }
    }

    // 3. Check generated code freshness
    final generator = CodeGenerator(
      projectRoot: resolvedRoot,
      config: config.generate,
    );

    final outputFile = File('${resolvedRoot.path}/${config.generate.output}');
    if (outputFile.existsSync()) {
      final upToDate = await generator.isUpToDate();
      if (upToDate) {
        logger.info('Generated code is up-to-date');
      } else {
        hasErrors = true;
        logger.err('Generated code is out of date — run `dart_assets gen`');
      }
    } else {
      logger.info('No generated code found (run `dart_assets gen` first)');
    }

    logger.info('');
    if (hasErrors) {
      logger.err('Asset check failed.');
      exitCode = 1;
    } else {
      logger.success('Asset check passed.');
    }
  }
}
