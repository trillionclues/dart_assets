import 'dart:io';
import 'package:path/path.dart' as p;

// Scans Dart source files to find assets not referenced anywhere
class UnusedAssetAnalyzer {
  final Directory projectRoot;

  UnusedAssetAnalyzer({required this.projectRoot});

  Future<List<String>> findUnusedAssets(List<String> declaredAssets) async {
    final libDir = Directory('${projectRoot.path}/lib');
    if (!libDir.existsSync()) return declaredAssets;

    final sourceContent = StringBuffer();
    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final relativePath = p.relative(entity.path, from: projectRoot.path);
        if (relativePath.startsWith('lib/gen/') ||
            relativePath.startsWith('lib${p.separator}gen${p.separator}')) {
          continue;
        }
        final content = await entity.readAsString();
        sourceContent.write(content);
      }
    }

    final source = sourceContent.toString();
    final unused = <String>[];

    for (final asset in declaredAssets) {
      if (asset.endsWith('/')) continue;

      if (!source.contains(asset)) {
        final basename = p.basenameWithoutExtension(asset);
        if (!source.contains(basename)) {
          unused.add(asset);
        }
      }
    }

    return unused;
  }
}
