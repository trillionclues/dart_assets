import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

import '../../generator/asset_scanner.dart';
import '../../models/config.dart';
import '../../optimizer/image_optimizer.dart';
import '../../utils/path_utils.dart';

// optimizes images for production
class OptimizeCommand extends Command<void> {
  final Logger logger;

  OptimizeCommand({required this.logger}) {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project root.',
        defaultsTo: '.',
      )
      ..addFlag(
        'webp',
        help: 'Convert images to WebP format.',
        defaultsTo: false,
      )
      ..addOption(
        'quality',
        help: 'JPEG quality (0-100).',
        defaultsTo: '85',
      )
      ..addFlag(
        'dry-run',
        help: 'Show what would be optimized without making changes.',
        defaultsTo: false,
      );
  }

  @override
  String get name => 'optimize';

  @override
  String get description => 'Optimize images for production';

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
    final dryRun = argResults?['dry-run'] as bool? ?? false;
    final webp = argResults?['webp'] as bool? ?? config.optimize.webp;
    final quality = int.tryParse(argResults?['quality'] as String? ?? '') ??
        config.optimize.jpegQuality;

    final progress = logger.progress('Scanning assets for optimization');

    final scanner = AssetScanner(projectRoot: resolvedRoot);
    final assets = await scanner.scan();
    final images = assets.where((a) => a.isImage).toList();

    if (images.isEmpty) {
      progress.complete('No images found.');
      return;
    }

    progress.complete('Found ${images.length} images');

    if (dryRun) {
      logger.info('\n📋 Dry run — no files will be modified:\n');
      for (final image in images) {
        final sizeKB = (image.fileSize / 1024).toStringAsFixed(1);
        logger.info('  📦 ${image.relativePath} (${sizeKB}KB)');
      }
      return;
    }

    final optimizer = ImageOptimizer(
      jpegQuality: quality,
      convertToWebP: webp,
    );

    var totalSaved = 0;
    var optimizedCount = 0;

    for (final image in images) {
      final file = File(p.join(resolvedRoot.path, image.relativePath));
      final result = await optimizer.optimize(file);

      if (!result.skipped && result.saved > 0) {
        final savedKB = (result.saved / 1024).toStringAsFixed(1);
        final percent =
            ((result.saved / (result.saved + file.lengthSync())) * 100)
                .toStringAsFixed(0);
        logger.info('  📦 ${image.relativePath}');
        logger.success('     Saved: ${savedKB}KB ($percent%)');
        totalSaved += result.saved;
        optimizedCount++;
      }
    }

    if (totalSaved > 0) {
      final totalKB = (totalSaved / 1024).toStringAsFixed(1);
      logger.info('');
      logger
          .success('Total savings: ${totalKB}KB across $optimizedCount files');
    } else {
      logger.info('\nAll images are already optimized.');
    }
  }
}
