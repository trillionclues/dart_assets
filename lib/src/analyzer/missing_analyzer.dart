import 'dart:io';

// finds assets listed in pubspec.yaml that don't exist on disk
class MissingAssetAnalyzer {
  final Directory projectRoot;

  MissingAssetAnalyzer({required this.projectRoot});

  Future<List<String>> findMissingAssets(List<String> declaredAssets) async {
    final missing = <String>[];

    for (final asset in declaredAssets) {
      final fullPath = '${projectRoot.path}/$asset';

      if (asset.endsWith('/')) {
        final dir = Directory(fullPath);
        if (!dir.existsSync()) {
          missing.add(asset);
        }
      } else {
        final file = File(fullPath);
        if (!file.existsSync()) {
          missing.add(asset);
        }
      }
    }

    return missing;
  }
}
