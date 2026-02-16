import 'dart:io';

import 'package:test/test.dart';
import 'package:dart_assets/src/parser/pubspec_parser.dart';

void main() {
  group('PubspecParser', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('pubspec_parser_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('parses valid pubspec with assets', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      pubspecFile.writeAsStringSync('''
name: test_app
flutter:
  assets:
    - assets/images/logo.png
    - assets/icons/
''');

      final parser = PubspecParser(pubspecFile);
      final assets = await parser.getAssets();

      expect(assets, hasLength(2));
      expect(assets, contains('assets/images/logo.png'));
      expect(assets, contains('assets/icons/'));
    });

    test('returns empty list when no assets section', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      pubspecFile.writeAsStringSync('''
name: test_app
flutter:
  uses-material-design: true
''');

      final parser = PubspecParser(pubspecFile);
      final assets = await parser.getAssets();

      expect(assets, isEmpty);
    });

    test('returns empty list when no flutter section', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      pubspecFile.writeAsStringSync('''
name: test_app
version: 1.0.0
''');

      final parser = PubspecParser(pubspecFile);
      final assets = await parser.getAssets();

      expect(assets, isEmpty);
    });

    test('hasAsset returns true for existing asset', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      pubspecFile.writeAsStringSync('''
name: test_app
flutter:
  assets:
    - assets/images/logo.png
''');

      final parser = PubspecParser(pubspecFile);

      expect(await parser.hasAsset('assets/images/logo.png'), isTrue);
      expect(await parser.hasAsset('assets/images/missing.png'), isFalse);
    });

    test('throws on invalid YAML', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      pubspecFile.writeAsStringSync('not: [valid: yaml: nope');

      final parser = PubspecParser(pubspecFile);

      expect(() => parser.parse(), throwsA(anything));
    });
  });
}
