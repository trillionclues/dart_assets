// Reads and parses pubspec.yaml

import 'dart:io';
import 'package:yaml/yaml.dart';

class PubspecParser {
  final File pubspecFile;

  PubspecParser(this.pubspecFile);

  // return the root map
  Future<YamlMap> parse() async {
    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content);

    if (yaml is! YamlMap) {
      throw InvalidPubspecError('pubspec.yaml is not a valid YAML map.');
    }

    return yaml;
  }

  // current list of asset paths from pubspec.yaml
  Future<List<String>> getAssets() async {
    final yaml = await parse();

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
      throw InvalidPubspecError('Failed to parse assets section: $e');
    }
  }

  // check if specific asset path is already in pubspec.yaml
  Future<bool> hasAsset(String assetPath) async {
    final assets = await getAssets();
    return assets.contains(assetPath);
  }
}

class InvalidPubspecError implements Exception {
  final String message;
  InvalidPubspecError(this.message);

  @override
  String toString() => 'InvalidPubspecError: $message';
}

class PubspecNotFoundError implements Exception {
  final String message;
  PubspecNotFoundError(this.message);

  @override
  String toString() => 'PubspecNotFoundError: $message';
}
