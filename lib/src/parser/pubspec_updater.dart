// adds and removes assets from pubspec.yaml while preserving
// comments, formatting, and key ordering

import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class PubspecUpdater {
  final File pubspecFile;

  PubspecUpdater(this.pubspecFile);

  // Add asset path to pubspec.yaml
  Future<void> addAsset(String assetPath) async {
    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content) as YamlMap;

    final currentAssets = _getAssetList(yaml);

    if (currentAssets.contains(assetPath)) return;

    final editor = YamlEditor(content);

    // check flutter section exists in pubspec
    if (!yaml.containsKey('flutter') || yaml['flutter'] == null) {
      editor.update([
        'flutter'
      ], {
        'assets': [assetPath]
      });
    } else if (yaml['flutter']['assets'] == null) {
      editor.update(['flutter', 'assets'], [assetPath]);
    } else {
      final newList = [...currentAssets, assetPath];
      editor.update(['flutter', 'assets'], newList);
    }

    await pubspecFile.writeAsString(editor.toString());
  }

  // remove asset path from pubspec.yaml
  Future<void> removeAsset(String assetPath) async {
    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content) as YamlMap;

    final currentAssets = _getAssetList(yaml);

    if (!currentAssets.contains(assetPath)) return;

    final editor = YamlEditor(content);
    final newList = currentAssets.where((a) => a != assetPath).toList();
    editor.update(['flutter', 'assets'], newList);

    await pubspecFile.writeAsString(editor.toString());
  }

  List<String> _getAssetList(YamlMap yaml) {
    try {
      final flutter = yaml['flutter'];
      if (flutter == null) return [];

      final assets = flutter['assets'];
      if (assets == null) return [];

      if (assets is YamlList) {
        return assets.map((e) => e.toString()).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
