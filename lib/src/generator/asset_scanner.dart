// Recursively scan assets directory and return metadata for each file

import 'dart:io';
import 'package:path/path.dart' as p;

import '../watcher/filters.dart';

class AssetScanner {
  final Directory projectRoot;

  AssetScanner({required this.projectRoot});

  Future<List<ScannedAsset>> scan() async {
    final assetsDir = Directory('${projectRoot.path}/assets');

    if (!assetsDir.existsSync()) {
      return [];
    }

    final assets = <ScannedAsset>[];

    await for (final entity in assetsDir.list(recursive: true)) {
      if (entity is File && FileFilter.isAsset(entity.path)) {
        final relativePath = p
            .relative(entity.path, from: projectRoot.path)
            .replaceAll(r'\', '/');
        final name = p.basenameWithoutExtension(entity.path);
        final extension = p.extension(entity.path).replaceFirst('.', '');
        final stat = await entity.stat();

        assets.add(ScannedAsset(
          relativePath: relativePath,
          name: name,
          extension: extension,
          fileSize: stat.size,
        ));
      }
    }

    assets.sort((a, b) => a.relativePath.compareTo(b.relativePath));
    return assets;
  }
}

// scanned asset file metadata
class ScannedAsset {
  final String relativePath;
  final String name;
  final String extension;
  final int fileSize;

  ScannedAsset({
    required this.relativePath,
    required this.name,
    required this.extension,
    required this.fileSize,
  });

  bool get isImage => const [
        'png',
        'jpg',
        'jpeg',
        'gif',
        'webp',
        'svg',
        'bmp',
      ].contains(extension.toLowerCase());

  bool get isFont => const [
        'ttf',
        'otf',
        'woff',
        'woff2',
      ].contains(extension.toLowerCase());

  bool get isVideo => const [
        'mp4',
        'mov',
        'avi',
        'mkv',
      ].contains(extension.toLowerCase());
}
