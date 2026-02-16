import 'dart:io';

import 'package:test/test.dart';
import 'package:dart_assets/src/parser/pubspec_updater.dart';

void main() {
  group('PubspecUpdater', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('pubspec_updater_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('adds asset to existing assets list', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      pubspecFile.writeAsStringSync('''
name: test_app

flutter:
  assets:
    - assets/images/logo.png
''');

      final updater = PubspecUpdater(pubspecFile);
      await updater.addAsset('assets/images/banner.png');

      final content = pubspecFile.readAsStringSync();
      expect(content, contains('assets/images/banner.png'));
      expect(content, contains('assets/images/logo.png'));
    });

    test('does not add duplicate asset', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      pubspecFile.writeAsStringSync('''
name: test_app

flutter:
  assets:
    - assets/images/logo.png
''');

      final updater = PubspecUpdater(pubspecFile);
      await updater.addAsset('assets/images/logo.png');

      final content = pubspecFile.readAsStringSync();
      final matches = 'assets/images/logo.png'.allMatches(content);
      expect(matches.length, equals(1));
    });

    test('removes asset from list', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      pubspecFile.writeAsStringSync('''
name: test_app

flutter:
  assets:
    - assets/images/logo.png
    - assets/images/banner.png
''');

      final updater = PubspecUpdater(pubspecFile);
      await updater.removeAsset('assets/images/logo.png');

      final content = pubspecFile.readAsStringSync();
      expect(content, isNot(contains('assets/images/logo.png')));
      expect(content, contains('assets/images/banner.png'));
    });

    test('does nothing when removing non-existent asset', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      final originalContent = '''
name: test_app

flutter:
  assets:
    - assets/images/logo.png
''';
      pubspecFile.writeAsStringSync(originalContent);

      final updater = PubspecUpdater(pubspecFile);
      await updater.removeAsset('assets/images/nonexistent.png');

      final content = pubspecFile.readAsStringSync();
      expect(content, contains('assets/images/logo.png'));
    });
  });
}
