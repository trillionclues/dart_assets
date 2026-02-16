import 'dart:io';
import 'package:yaml/yaml.dart';

class DartAssetsConfig {
  final WatchConfig watch;
  final GenerateConfig generate;
  final OptimizeConfig optimize;
  final AnalyzeConfig analyze;

  DartAssetsConfig({
    WatchConfig? watch,
    GenerateConfig? generate,
    OptimizeConfig? optimize,
    AnalyzeConfig? analyze,
  })  : watch = watch ?? WatchConfig(),
        generate = generate ?? GenerateConfig(),
        optimize = optimize ?? OptimizeConfig(),
        analyze = analyze ?? AnalyzeConfig();

  // load config from `dart_assets.yaml` in the given directory
  // returns defaults if the file doesn't exist
  static Future<DartAssetsConfig> load(Directory projectRoot) async {
    final configFile = File('${projectRoot.path}/dart_assets.yaml');

    if (!configFile.existsSync()) {
      return DartAssetsConfig();
    }

    final content = await configFile.readAsString();
    final yaml = loadYaml(content) as YamlMap;

    return DartAssetsConfig(
      watch: WatchConfig.fromYaml(yaml['watch']),
      generate: GenerateConfig.fromYaml(yaml['generate']),
      optimize: OptimizeConfig.fromYaml(yaml['optimize']),
      analyze: AnalyzeConfig.fromYaml(yaml['analyze']),
    );
  }
}

class WatchConfig {
  final int debounceMs;

  WatchConfig({this.debounceMs = 500});

  factory WatchConfig.fromYaml(dynamic yaml) {
    if (yaml == null) return WatchConfig();
    return WatchConfig(debounceMs: yaml['debounce_ms'] ?? 500);
  }
}

class GenerateConfig {
  final String output;
  final String className;

  GenerateConfig({
    this.output = 'lib/gen/assets.dart',
    this.className = 'Assets',
  });

  factory GenerateConfig.fromYaml(dynamic yaml) {
    if (yaml == null) return GenerateConfig();
    return GenerateConfig(
      output: yaml['output'] ?? 'lib/gen/assets.dart',
      className: yaml['class_name'] ?? 'Assets',
    );
  }
}

class OptimizeConfig {
  final int maxFileSizeKb;
  final int jpegQuality;
  final bool webp;

  OptimizeConfig({
    this.maxFileSizeKb = 500,
    this.jpegQuality = 85,
    this.webp = false,
  });

  factory OptimizeConfig.fromYaml(dynamic yaml) {
    if (yaml == null) return OptimizeConfig();
    return OptimizeConfig(
      maxFileSizeKb: yaml['max_file_size_kb'] ?? 500,
      jpegQuality: yaml['jpeg_quality'] ?? 85,
      webp: yaml['webp'] ?? false,
    );
  }
}

class AnalyzeConfig {
  final List<String> exclude;

  AnalyzeConfig({this.exclude = const []});

  factory AnalyzeConfig.fromYaml(dynamic yaml) {
    if (yaml == null) return AnalyzeConfig();
    final excludeList = yaml['exclude'];
    return AnalyzeConfig(
      exclude: excludeList is YamlList
          ? excludeList.map((e) => e.toString()).toList()
          : [],
    );
  }
}
