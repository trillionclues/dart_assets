import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../../models/config.dart';
import '../../utils/path_utils.dart';

// diagnoses common asset configuration issues
class DoctorCommand extends Command<void> {
  final Logger logger;

  DoctorCommand({required this.logger}) {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Path to the Flutter project root.',
      defaultsTo: '.',
    );
  }

  @override
  String get name => 'doctor';

  @override
  String get description => 'Diagnose common asset configuration issues';

  @override
  Future<void> run() async {
    final projectPath = argResults?['path'] as String? ?? '.';
    final projectRoot = Directory(projectPath).absolute;

    final resolvedRoot = PathUtils.findProjectRoot(projectRoot);
    if (resolvedRoot == null) {
      logger.err('No pubspec.yaml found in $projectPath or parent dirs.');
      return;
    }

    logger.info('🩺 dart_assets doctor\n');
    var issues = 0;

    // 1. pubspec.yaml
    final pubspecFile = File('${resolvedRoot.path}/pubspec.yaml');
    if (pubspecFile.existsSync()) {
      logger.info(' pubspec.yaml found');
    } else {
      logger.err(' pubspec.yaml not found');
      issues++;
    }

    // 2. assets/ directory
    final assetsDir = Directory('${resolvedRoot.path}/assets');
    if (assetsDir.existsSync()) {
      final fileCount =
          assetsDir.listSync(recursive: true).whereType<File>().length;
      logger.info(' assets/ directory found ($fileCount files)');
    } else {
      logger.warn(' assets/ directory not found');
      logger.info('     Create it with: mkdir assets');
      issues++;
    }

    // 3. Flutter section in pubspec.yaml
    if (pubspecFile.existsSync()) {
      final content = await pubspecFile.readAsString();
      if (content.contains('flutter:')) {
        logger.info(' flutter section exists in pubspec.yaml');

        if (content.contains('assets:')) {
          logger.info(' assets section found in flutter config');
        } else {
          logger.warn(' No assets section in flutter config');
          logger.info("     Run 'dart_assets gen' to auto-configure");
          issues++;
        }
      } else {
        logger.warn(' No flutter section in pubspec.yaml');
        issues++;
      }
    }

    // 4. dart_assets.yaml config file
    final configFile = File('${resolvedRoot.path}/dart_assets.yaml');
    if (configFile.existsSync()) {
      logger.info(' dart_assets.yaml config found');
      try {
        await DartAssetsConfig.load(resolvedRoot);
        logger.info(' Config is valid');
      } catch (e) {
        logger.err(' Config has errors: $e');
        issues++;
      }
    } else {
      logger.info(' dart_assets.yaml not found (using defaults)');
    }

    // 5. Generated code file
    final config = await DartAssetsConfig.load(resolvedRoot);
    final generatedFile =
        File('${resolvedRoot.path}/${config.generate.output}');
    if (generatedFile.existsSync()) {
      logger.info(' Generated code exists at ${config.generate.output}');
    } else {
      logger.warn(' No generated code found');
      logger.info("     Run 'dart_assets gen' to generate");
    }

    // Summary
    logger.info('');
    if (issues == 0) {
      logger.success('No issues found!');
    } else {
      logger.warn(
          'Found $issues issue${issues > 1 ? 's' : ''} — see above for details.');
    }
  }
}
